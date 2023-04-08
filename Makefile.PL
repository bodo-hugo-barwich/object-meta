use ExtUtils::MakeMaker;
 


WriteMakefile(
    NAME             => 'Object::Meta',
    LICENSE          => 'perl',
    AUTHOR           => 'Bodo (Hugo) Barwich <b.barwich@hotmail.com>',
    VERSION_FROM     => 'lib/Object/Meta.pm',
    MIN_PERL_VERSION => '5.10',
    test             => {TESTS => 't/*.t'},
    META_MERGE          => {
        resources       => {
            repository  => "https://github.com/bodo-hugo-barwich/object-meta",
        },
    },
);

