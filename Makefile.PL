use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'DateTime::LeapSecond',
    'VERSION_FROM'	=> 'lib/DateTime/LeapSecond.pm',
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/DateTime/LeapSecond.pm', # retrieve abstract from module
       AUTHOR     => 'Flávio Soibelmann Glock <fglock@pucrs.br>') : ()),
);
