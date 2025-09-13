# completion file for vmrss command that shows the memory usage of a process 

alias __get_process_list='__fish_complete_pids | awk "{print \$1\":\"\$2}"'
for process in (__get_process_list);
     set pid (echo $process | cut -d: -f1)
     set name (echo $process | cut -d: -f2)
     complete --command vmrss --exclusive --arguments $pid --description $name
end


