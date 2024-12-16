/* persistent.c */
 #include <EXTERN.h>
 #include <perl.h>

 /* 1 = clean out filename's symbol table after each request,
    0 = don't
 */
 #ifndef DO_CLEAN
 #define DO_CLEAN 0
 #endif

 #define BUFFER_SIZE 1024

 static PerlInterpreter *my_perl = NULL;

 int
 main(int argc, char **argv, char **env)
 {
     char *embedding[] = { "", "persistent.pl", NULL };
     char *args[] = { "", DO_CLEAN, NULL };
     char filename[BUFFER_SIZE];
     int failing, exitstatus;

     PERL_SYS_INIT3(&argc,&argv,&env);
     if((my_perl = perl_alloc()) == NULL) {
        fprintf(stderr, "no memory!");
        exit(EXIT_FAILURE);
     }
     perl_construct(my_perl);

     PL_origalen = 1; /* don't let $0 assignment update the
                         proctitle or embedding[0] */
     failing = perl_parse(my_perl, NULL, 2, embedding, NULL);
     PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
     if(!failing)
	failing = perl_run(my_perl);
     if(!failing) {
        while(printf("Enter file name: ") &&
              fgets(filename, BUFFER_SIZE, stdin)) {

            filename[strlen(filename)-1] = '\0'; /* strip \n */
            /* call the subroutine,
                     passing it the filename as an argument */
            args[0] = filename;
            call_argv("Embed::Persistent::eval_file",
                           G_DISCARD | G_EVAL, args);

            /* check $@ */
            if(SvTRUE(ERRSV))
                fprintf(stderr, "eval error: %s\n", SvPV_nolen(ERRSV));
        }
     }

     PL_perl_destruct_level = 0;
     exitstatus = perl_destruct(my_perl);
     perl_free(my_perl);
     PERL_SYS_TERM();
     exit(exitstatus);
 }
