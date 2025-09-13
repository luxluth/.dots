pub mod job {
    use std::{
        sync::{
            Arc,
            atomic::{AtomicUsize, Ordering},
        },
        thread::Result,
        time::{Duration, SystemTime},
    };
    use tokio::{sync::mpsc, time};

    static TASK_ID: AtomicUsize = AtomicUsize::new(1);

    pub struct Task {
        pub id: usize,
        at: SystemTime,
        after: Duration,
        task: Arc<Box<dyn Fn() + 'static + Send + Sync>>,
    }

    impl Task {
        pub fn new<C: Fn() + 'static + Send + Sync>(cb: C, after: Duration) -> Self {
            Self {
                id: TASK_ID.fetch_add(1, Ordering::Relaxed),
                at: SystemTime::now(),
                after,
                task: Arc::new(Box::new(cb)),
            }
        }
    }

    pub enum SchedulerMessage {
        AddTask(Task),
        RemoveTask(usize),
        Stop,
    }

    pub struct TaskScheduler {
        tasks: Vec<Task>,
        removals: Vec<usize>,
        recv: mpsc::UnboundedReceiver<SchedulerMessage>,
    }

    impl TaskScheduler {
        pub fn new() -> (mpsc::UnboundedSender<SchedulerMessage>, Self) {
            let (tx, rx) = mpsc::unbounded_channel();
            (
                tx,
                Self {
                    tasks: vec![],
                    removals: vec![],
                    recv: rx,
                },
            )
        }

        pub async fn run(mut self) -> Result<()> {
            'run: loop {
                let mut to_remove = vec![];

                while let Ok(msg) = self.recv.try_recv() {
                    match msg {
                        SchedulerMessage::AddTask(task) => {
                            self.tasks.push(task);
                        }
                        SchedulerMessage::RemoveTask(id) => {
                            to_remove.push(id);
                        }
                        SchedulerMessage::Stop => break 'run,
                    }
                }

                let now = SystemTime::now();
                for task in &self.tasks {
                    if !to_remove.contains(&task.id) {
                        if now.duration_since(task.at).unwrap() >= task.after {
                            to_remove.push(task.id);
                            (task.task)();
                        }
                    }
                }

                self.removals.extend(to_remove);
                self.tasks.retain(|task| !self.removals.contains(&task.id));
                self.removals.clear();

                time::sleep(Duration::from_millis(10)).await;
            }

            Ok(())
        }
    }
}
