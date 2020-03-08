use nqp;
use QAST:from<NQP>;
use Inline::Perl5;

sub EXPORT(|) {
    my role TestSlang {
        method p5code { 
            my $pos  = self.pos;
            my $end = Inline::Perl5.default_perl5.compile-to-block-end('{' ~ substr(self.target, $pos)) - 2;
            $*P5CODE = self.target.substr($pos, *-$end);
            self.'!cursor_pass'(self.target.chars - $end);
            self
        }
        token statement_control {
            :my $*P5CODE;
            <.p5code>
        }
    }

    my Mu $MAIN-grammar := nqp::atkey(%*LANG, 'MAIN');
    my $grammar := $MAIN-grammar.HOW.mixin($MAIN-grammar, TestSlang);

    $*LANG.define_slang(
        'MAIN',
        $grammar,
        $*LANG.actions but role :: {
            method statement_control(Mu $/) {
                make QAST::Op.new(
                    :op<callmethod>,
                    :name<run>,
                    QAST::Op.new(
                        :op<callmethod>,
                        :name<default_perl5>,
                        QAST::WVal.new(:value(Inline::Perl5)),
                    ),
                    QAST::SVal.new(:value($*P5CODE))
                );
            }
        });

    Map.new
}
