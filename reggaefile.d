import reggae;
enum commonFlags = "-w -g -debug";

alias lib = dubDefaultTarget!(CompilerFlags(commonFlags));
alias ut = dubTestTarget!(CompilerFlags(commonFlags));
alias asan = dubConfigurationTarget!(
    Configuration("asan"),
    CompilerFlags(commonFlags ~ " -unittest -cov -fsanitize=address"),
    LinkerFlags("-fsanitize=address"),
);

mixin build!(ut, optional!lib, optional!asan);
