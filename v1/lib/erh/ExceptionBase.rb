
class ExceptionBase < Exception ##{{{
    attr_accessor :exitSig;
    attr_accessor :exitMsg;
    attr_accessor :eFlag;
	attr_accessor :noexit;

    ## supports error level
    ## :WARNING, :ERROR, :FATAL
    attr_accessor :elevel;
	attr :extMsg;

    def initialize ##{
        @exitSig = 0;
        @exitMsg = '';
		@extMsg  = '';
        @eFlag   = 'BERR';
        @elevel  = :WARNING;
		@noexit  = false;
    end #}
    def __shallexit__ ##{{{
		return false if @noexit;
        return true if @elevel==:ERROR or @elevel==:FATAL;
        return false;
    end ##}}}
    def process msg=nil ##{
        @exitMsg = msg.to_s if msg!=nil;
        stack = caller(1);
        puts "\n[#{@elevel},#{@eFlag}] #{@exitMsg}#{@extMsg} ";
        puts "----- Tracing Stack -----:\n",stack;
        exit @exitSig if __shallexit__;
    end ##}
    def self.message msg; @exitMsg=msg; end
end ##}}}
