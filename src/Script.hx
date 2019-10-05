// region scanner
enum Tokens {
    LEFT_PAREN; RIGHT_PAREN;
    MINUS; PLUS; DIVIDE; MULTIPLY;
    MODULO; COLON; DOT; SPACE; EOF;

    EQUAL; EQUAL_EQUAL;
    GREATER; GREATER_EQUAL;
    LESS; LESS_EQUAL;

    LABEL; END; JUMP; IF; ELSE; ELIF;
    WHILE; NOT; AND; OR; TRUE; FALSE;
    MENU; CHOICE; EVENT;
    IDENTIFIER; STRING; NUMBER;
}

class Token {
    public var type: Tokens;
    public var value: Dynamic;
    public var line: Int;
    public var pos: Int;

    public function new(line: Int, pos: Int, type: Tokens, value: Dynamic=null) {
        this.line = line;
        this.pos = pos;
        this.type = type;
        this.value = value;
    }

    public function toString(): String {
        return 'Type: $type, Value: $value';
    }
}

class BinaryExpression {
    public var a: Dynamic;
    public var b: Dynamic;
    public var op: Tokens;

    public function new(a: Dynamic, b: Dynamic, op: Tokens) {
        this.a = a;
        this.b = b;
        this.op = op;
    }

    public function toString(): String {
        return '$a $op $b';
    }

    public static function evaluate(a: Dynamic, b: Dynamic, op: Tokens): Dynamic {
        switch (op) {
            case Tokens.MINUS: return a - b;
            case Tokens.PLUS: return a + b;
            case Tokens.DIVIDE: return a / b;
            case Tokens.MULTIPLY: return a * b;
            case Tokens.MODULO: return a % b;
            case Tokens.EQUAL_EQUAL: return a == b;
            case Tokens.GREATER: return a > b;
            case Tokens.GREATER_EQUAL: return a >= b;
            case Tokens.LESS: return a < b;
            case Tokens.LESS_EQUAL: return a <= b;
            case Tokens.AND: return a && b;
            case Tokens.OR: return a || b;
            default: return null;
        }
    }
}

class UnaryExpression {
    public var value: Dynamic;
    public var op: Tokens;

    public function new(value: Dynamic, op: Tokens) {
        this.value = value;
        this.op = op;
    }

    public function toString(): String {
        return '$op $value';
    }

    public static function evaluate(value: Dynamic, op: Tokens): Dynamic {
        switch (op) {
            case Tokens.NOT: return !value;
            default: return null;
        }
    }
}

class Scanner {
    var i: Int;
    var str: String;
    
    public function new() {
        //
    }

    public function tokenize(str: String): Array<Array<Token>> {
        i = 0;
        this.str = str;
        var line = 1;
        var isub = 0;
        var char: String, start: Int;
        var tokens: Array<Array<Token>> = [[]];

        while (i < str.length) {
            start = i;
            char = str.charAt(i);
            switch (char) {
                case "#": while (!peakNext("\n") && i < str.length) i++; i++; continue;

                case "(": tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.LEFT_PAREN)); i++; continue;
                case ")": tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.RIGHT_PAREN)); i++; continue;
                case "-":
                    var isBinary = false;
                    var _tokens = tokens[tokens.length - 1].copy();
                    _tokens.reverse();
                    for (token in _tokens) {
                        if (token.type == Tokens.SPACE) continue;
                        if (token.type == Tokens.NUMBER || token.type == Tokens.IDENTIFIER) isBinary = true;
                        break;
                    }
                    if (isBinary) {
                        tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.MINUS));
                        i++;
                        continue;
                    }
                case "+": tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.PLUS)); i++; continue;
                case "/": tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.DIVIDE)); i++; continue;
                case "*": tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.MULTIPLY)); i++; continue;
                case "%": tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.MODULO)); i++; continue;
                case ":": tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.COLON)); i++; continue;
                case ".": tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.DOT)); i++; continue;
                case " ": tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.SPACE)); i++; continue;
                case "\n": if (tokens[tokens.length - 1].length > 0) tokens.push(new Array<Token>()); i++; isub = i; line++; continue;
                case "\t": i++; continue;
                case "\r": i++; continue;

                case "=": if (eatNext("=")) tokens[tokens.length - 1].push(new Token(line, start - isub + 1, EQUAL_EQUAL)); else tokens[tokens.length - 1].push(new Token(line, start - isub + 1, EQUAL)); i++; continue;
                case ">": if (eatNext("=")) tokens[tokens.length - 1].push(new Token(line, start - isub + 1, GREATER_EQUAL)); else tokens[tokens.length - 1].push(new Token(line, start - isub + 1, GREATER)); i++; continue;
                case "<": if (eatNext("=")) tokens[tokens.length - 1].push(new Token(line, start - isub + 1, LESS_EQUAL)); else tokens[tokens.length - 1].push(new Token(line, start - isub + 1, LESS)); i++; continue;

                case "i": if (eatNext("f")) {tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.IF)); i++; continue;}
                case "o": if (eatNext("r")) {tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.OR)); i++; continue;}
                case "n": if (eatNext("o") && eatNext("t")) {tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.NOT)); i++; continue;} else i = start;
                case "a": if (eatNext("n") && eatNext("d")) {tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.AND)); i++; continue;} else i = start;

                case "t":
                    if (eatNext("r") && eatNext("u") && eatNext("e")) {
                        tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.TRUE));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "f":
                    if (eatNext("a") && eatNext("l") && eatNext("s") && eatNext("e")) {
                        tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.FALSE));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "w":
                    if (eatNext("h") && eatNext("i") && eatNext("l") && eatNext("e")) {
                        tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.WHILE));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "l":
                    if (eatNext("a") && eatNext("b") && eatNext("e") && eatNext("l")) {
                        tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.LABEL));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "j":
                    if (eatNext("u") && eatNext("m") && eatNext("p")) {
                        tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.JUMP));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "e":
                    if (eatNext("l")) {
                        if (eatNext("s") && eatNext("e")) {
                            tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.ELSE));
                            i++;
                            continue;
                        } else {
                            i = start + 1;
                            if (eatNext("i") && eatNext("f")) {
                                tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.ELIF));
                                i++;
                                continue;
                            } else {
                                i = start;
                            }
                        }
                    } else if (eatNext("n") && eatNext("d")) {
                        tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.END));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "m":
                    if (eatNext("e") && eatNext("n") && eatNext("u")) {
                        tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.MENU));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                case "c":
                    if (eatNext("h") && eatNext("o") && eatNext("i") && eatNext("c") && eatNext("e")) {
                        tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.CHOICE));
                        i++;
                        continue;
                    } else {
                        i = start;
                    }
                
                case "\"":
                    var value = "";
                    while (i < str.length) {
                        i++;
                        char = str.charAt(i);
                        if (char == "\"") break;
                        if (char == "\\") {
                            if (eatNext("\n")) continue;
                            else if (eatNext("\\")) value += "\\";
                            else if (eatNext("\"")) value += "\"";
                            else if (eatNext("\"")) value += "\"";
                            else if (eatNext("\n")) value += "\n";
                            else if (eatNext("\r")) value += "\r";
                            else if (eatNext("\t")) value += "\t";
                            else value += str.charAt(i++);
                        } else {
                            value += char;
                        }
                    }
                    tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.STRING, value));
                    i++;
                    continue;
            }

            var value = "";

            if (isSafe(0, false) && !isNumber(0)) {
                while (isSafe(0)) {
                    value += str.charAt(i);
                    i++;
                }
                tokens[tokens.length - 1].push(new Token(line, start - isub + 1, (Executer.eventNames.indexOf(value) != -1)? Tokens.EVENT:Tokens.IDENTIFIER, value));
                continue;
            }
            
            if (isNumber(0) || char == "." || char == "-") {
                var mult: Int = 1;
                var seenDot = false;
                if (char == "-") {
                    i++;
                    mult = -1;
                }
                while (isNumber(0) || (!seenDot && (seenDot = str.charAt(i) == '.'))) {
                    value += str.charAt(i);
                    i++;
                }
                tokens[tokens.length - 1].push(new Token(line, start - isub + 1, Tokens.NUMBER, Std.parseFloat(value) * mult));
                continue;
            }

            throw 'RH: Unknown character $char at position $i';
            i++;
        }

        tokens[tokens.length - 1].push(new Token(line, i - isub + 1, Tokens.EOF));
        return tokens;
    }

    private function eatNext(char: String): Bool {
        if (peakNext(char)) {
            i++;
            return true;
        }
        return false;
    }

    private function peakNext(char: String): Bool {
        if (i + 1 >= str.length) return false;
        else return (str.charAt(i + 1) == char);
    }

    private function isSafe(n:Int = 1, includeDot:Bool = true) {
        if (i + n >= str.length) return false;
        var charCode: Int = str.charCodeAt(i + n);
        if (charCode >= 65 && charCode <= 90) return true;
        if (charCode >= 97 && charCode <= 122) return true;
        if (charCode >= 48 && charCode <= 57) return true;
        if (charCode == 95) return true;
        return charCode == 46 && includeDot;
    }

    private function isNumber(n:Int = 1) {
        if (i + n >= str.length) return false;
        var charCode: Int = str.charCodeAt(i + n);
        return charCode >= 48 && charCode <= 57;
    }
}
// end region
// region parser
class ScriptCommand {
    public function new() {}
    public function toString() {return Type.getClassName(Type.getClass(this));}
}

class Label extends ScriptCommand {
    public var commands = new Array<ScriptCommand>();
}

class If extends ScriptCommand {
    public var condition: Dynamic;
    public var commands = new Array<ScriptCommand>();
    public var elifCmds = new Array<Elif>();
    public var elseCmd: Else;

    public function new(condition: Dynamic) {
        super();
        this.condition = condition;
    }

    override public function toString() {
        var temp = 'if $condition then $commands';
        for (elifCmd in elifCmds) {
            temp += ' elif ${elifCmd.condition} then ${elifCmd.commands}';
        }
        if (elseCmd != null) {
            temp += ' else ${elseCmd.commands}';
        }
        return temp;
    }
}

class Elif extends ScriptCommand {
    public var condition: Dynamic;
    public var commands = new Array<ScriptCommand>();

    public function new(condition: Dynamic) {
        super();
        this.condition = condition;
    }
}

class Else extends ScriptCommand {
    public var commands = new Array<ScriptCommand>();
}

class While extends ScriptCommand {
    public var condition: Dynamic;
    public var commands = new Array<ScriptCommand>();

    public function new(condition: Dynamic) {
        super();
        this.condition = condition;
    }

    override public function toString() {
        return 'while $condition do $commands';
    }
}

class RegularEventCall extends ScriptCommand {
    public var event: String;
    public var args: Array<Dynamic>;

    public function new(event: String, args: Array<Dynamic>) {
        super();
        this.event = event;
        this.args = args;
    }

    override public function toString() {
        return 'call event $event with args $args';
    }
}

class Menu extends ScriptCommand {
    public var choices = new Array<Choice>();

    override public function toString() {
        return 'menu with choices: $choices';
    }
}

class Choice extends ScriptCommand {
    public var value: Dynamic;
    public var commands = new Array<ScriptCommand>();

    public function new(value: Dynamic) {
        super();
        this.value = value;
    }

    override public function toString() {
        return 'choice $value: $commands';
    }
}

class Jump extends ScriptCommand {
    public var label: String;

    public function new(label: String) {
        super();
        this.label = label;
    }

    override public function toString() {
        return 'jump to label $label';
    }
}

class SetVariable extends ScriptCommand {
    public var variable: String;
    public var value: Dynamic;
    
    public function new(variable: String, value: Dynamic) {
        super();
        this.variable = variable;
        this.value = value;
    }

    override public function toString() {
        return 'set value of variable $variable to $value';
    }
}

class Parser {
    public static function parse(lines: Array<Array<Token>>): Map<String, Label> {
        var labels = new Map<String, Label>();
        var blockHierarchy = new Array<Dynamic>();
        for (i in 0...lines.length) {
            var line = lines[i].copy();
            while (line.length > 0 && line[0].type == Tokens.SPACE) {
                line.shift();
            }
            if (line.length == 0) continue;
            switch (line[0].type) {
                case Tokens.LABEL:
                    if (blockHierarchy.length > 0) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: found nested label; missing end?';
                    }
                    var label = new Label();
                    line.shift();
                    while (line[0].type == Tokens.SPACE) {
                        line.shift();
                    }
                    labels[line[0].value] = label;
                    blockHierarchy[0] = label;
                case Tokens.IF:
                    if (Std.is(blockHierarchy[0], Menu)) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: expected choice inside menu, got ${line[0]}';
                    }
                    line.shift();
                    while (line[0].type == Tokens.SPACE) {
                        line.shift();
                    }
                    var ifCmd = new If(parseExpression(line));
                    blockHierarchy[0].commands.push(ifCmd);
                    blockHierarchy.unshift(ifCmd);
                case Tokens.ELIF:
                    if (Std.is(blockHierarchy[0], Menu)) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: expected choice inside menu, got ${line[0]}';
                    }
                    line.shift();
                    while (line[0].type == Tokens.SPACE) {
                        line.shift();
                    }
                    if (!Std.is(blockHierarchy[0], If) && !Std.is(blockHierarchy[0], Elif)) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: elif used outside if block';
                    }
                    var elifCmd = new Elif(parseExpression(line));
                    var ifCmd: If = null;
                    for (block in blockHierarchy) {
                        if (Std.is(block, If)) {
                            ifCmd = block;
                            break;
                        }
                    }
                    ifCmd.elifCmds.push(elifCmd);
                    blockHierarchy.unshift(elifCmd);
                case Tokens.ELSE:
                    if (Std.is(blockHierarchy[0], Menu)) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: expected choice inside menu, got ${line[0]}';
                    }
                    if (!Std.is(blockHierarchy[0], If) && !Std.is(blockHierarchy[0], Elif)) {
                        throw "RH <Line ${i + 1}>: else used outside if block";
                    }
                    var elseCmd = new Else();
                    var ifCmd: If = null;
                    for (block in blockHierarchy) {
                        if (Std.is(block, If)) {
                            ifCmd = block;
                            break;
                        }
                    }
                    ifCmd.elseCmd = elseCmd;
                    blockHierarchy.unshift(elseCmd);
                case Tokens.WHILE:
                    if (Std.is(blockHierarchy[0], Menu)) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: expected choice inside menu, got ${line[0]}';
                    }
                    line.shift();
                    while (line[0].type == Tokens.SPACE) {
                        line.shift();
                    }
                    var whileCmd = new While(parseExpression(line));
                    blockHierarchy[0].commands.push(whileCmd);
                    blockHierarchy.unshift(whileCmd);
                case Tokens.MENU:
                    if (Std.is(blockHierarchy[0], Menu)) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: expected choice inside menu, got ${line[0]}';
                    }
                    var menuCmd = new Menu();
                    blockHierarchy[0].commands.push(menuCmd);
                    blockHierarchy.unshift(menuCmd);
                case Tokens.CHOICE:
                    if (!Std.is(blockHierarchy[0], Menu)) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: found choice outside of menu';
                    }
                    line.shift();
                    while (line[0].type == Tokens.SPACE) {
                        line.shift();
                    }
                    var choiceCmd = new Choice(parseExpression(line));
                    blockHierarchy[0].choices.push(choiceCmd);
                    blockHierarchy.unshift(choiceCmd);
                case Tokens.JUMP:
                    if (Std.is(blockHierarchy[0], Menu)) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: expected choice inside menu, got ${line[0]}';
                    }
                    line.shift();
                    while (line[0].type == Tokens.SPACE) {
                        line.shift();
                    }
                    blockHierarchy[0].commands.push(new Jump(line[0].value));
                case Tokens.IDENTIFIER:
                    if (Std.is(blockHierarchy[0], Menu)) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: expected choice inside menu, got ${line[0]}';
                    }
                    var initialToken = line.shift();
                    while (line[0].type == Tokens.SPACE) {
                        line.shift();
                    }
                    if (line[0].type == Tokens.EQUAL) {
                        line.shift();
                        blockHierarchy[0].commands.push(new SetVariable(initialToken.value, parseExpression(line)));
                    } else {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: expected equal sign after identifier, got ${line[0].type}';
                    }
                case Tokens.EVENT:
                    if (Std.is(blockHierarchy[0], Menu)) {
                        throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: expected choice inside menu, got ${line[0]}';
                    }
                    var initialToken = line.shift();
                    while (line[0].type == Tokens.SPACE) {
                        line.shift();
                    }
                    var args = new Array<Array<Token>>();
                    var arg = new Array<Token>();
                    while (line.length > 0 && line[0].type != Tokens.EOF) {
                        if (line[0].type == Tokens.SPACE) {
                            line.shift();
                            args.push(parseExpression(arg));
                            arg = new Array<Token>();
                        } else {
                            arg.push(line.shift());
                        }
                    }
                    if (arg.length > 0) args.push(parseExpression(arg));
                    blockHierarchy[0].commands.push(new RegularEventCall(initialToken.value, args));
                case Tokens.END:
                    while (Std.is(blockHierarchy[0], Elif) || Std.is(blockHierarchy[0], Else)) {
                        blockHierarchy.shift();
                    }
                    blockHierarchy.shift();
                default:
                    throw 'RH <Line ${line[0].line} Position ${line[0].pos}>: unexpected token ${line[0].type} at start of line';
            }
        }
        return labels;
    }

    public static function parseExpression(_tokens: Array<Token>): Dynamic {
        var tokens = new Array<Token>();
        var inParentheses = false;
        
        var __tokens = _tokens.copy();
        while (__tokens.length > 0) {
            if (__tokens[0].type == Tokens.SPACE) __tokens.shift();
            else tokens.push(__tokens.shift());
        }

        if (tokens.length > 0 && tokens[0].type == Tokens.LEFT_PAREN && tokens[tokens.length - 1].type == Tokens.RIGHT_PAREN) {
            tokens.shift();
            tokens.pop();
        }

        var j: Int = tokens.length - 1;
        while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) {j--; continue;}

            if (tokens[j].type == Tokens.OR) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.OR);
            }

            j--;
        }

        j = tokens.length - 1;
        while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) {j--; continue;}

            if (tokens[j].type == Tokens.AND) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.AND);
            }

            j--;
        }

        j = tokens.length - 1;
        while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) {j--; continue;}

            if (tokens[j].type == Tokens.NOT) {
                return new UnaryExpression(parseExpression(tokens.slice(j + 1)), Tokens.NOT);
            }

            j--;
        }
        
        inParentheses = false;
        j = tokens.length - 1;
        while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) {j--; continue;}

            if (tokens[j].type == Tokens.EQUAL_EQUAL) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.EQUAL_EQUAL);
            } else if (tokens[j].type == Tokens.LESS) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.LESS);
            } else if (tokens[j].type == Tokens.LESS_EQUAL) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.LESS_EQUAL);
            } else if (tokens[j].type == Tokens.GREATER) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.GREATER);
            } else if (tokens[j].type == Tokens.GREATER_EQUAL) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.GREATER_EQUAL);
            }

            j--;
        }

        inParentheses = false;
        j = tokens.length - 1;
		while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) {j--; continue;}

            if (tokens[j].type == Tokens.PLUS) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.PLUS);
            } else if (tokens[j].type == Tokens.MINUS) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.MINUS);
            }

            j--;
        }

        inParentheses = false;
        j = tokens.length - 1;
		while (j >= 0) {
            if (tokens[j].type == Tokens.RIGHT_PAREN) inParentheses = true;
            if (tokens[j].type == Tokens.LEFT_PAREN) inParentheses = false;
            if (inParentheses) {j--; continue;}

            if (tokens[j].type == Tokens.DIVIDE) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.DIVIDE);
            } else if (tokens[j].type == Tokens.MULTIPLY) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.MULTIPLY);
            } else if (tokens[j].type == Tokens.MODULO) {
                return new BinaryExpression(parseExpression(tokens.slice(0, j)), parseExpression(tokens.slice(j + 1)), Tokens.MODULO);
            }
            
            j--;
        }

        return tokens[0];
    }

    public static function evaluateExpression(subtree: Dynamic, variables: Map<String, Dynamic>): Dynamic {
        if (Std.is(subtree, BinaryExpression)) {
            var _subtree = cast (subtree, BinaryExpression);
            return BinaryExpression.evaluate(evaluateExpression(_subtree.a, variables), evaluateExpression(_subtree.b, variables), _subtree.op);
        } else if (Std.is(subtree, UnaryExpression)) {
            var _subtree = cast (subtree, UnaryExpression);
            return UnaryExpression.evaluate(evaluateExpression(_subtree.value, variables), _subtree.op);
        } else if (Std.is(subtree, Token)) {
            var _subtree = cast (subtree, Token);
            switch (_subtree.type) {
                case Tokens.NUMBER: return _subtree.value;
                case Tokens.STRING: return _subtree.value;
                case Tokens.IDENTIFIER: return variables.get(_subtree.value);
                case Tokens.TRUE: return true;
                case Tokens.FALSE: return false;
                default: return null;
            }
        }
        return null;
    }
}
// end region
// region executer
typedef ScriptProcess = {
    public var command: Dynamic;
    public var index: Int;
}

class Executer {
    public static final eventNames = [
        "message",
        "delay",
        "cameramode",
        "camerawalk",
        "shake"
    ];

    public var callback: Void->Void;
    public var labels: Map<String, Label>;
    public var running: Bool = false;
    public var variables: Map<String, Dynamic> = [];
    var runHierarchy: Array<ScriptProcess>;

    var messageBox = new Event.MessageBox();
    var delay = new Event.Delay();
    var cameraWalk = new Event.CameraWalk();
    var screenShake = new Event.ScreenShake();

    public function new(callback: Void->Void, labels: Map<String, Label>) {
        this.callback = callback;
        this.labels = labels;
    }

    public function execute(entryPoint="main") {
        runHierarchy = [{command: labels[entryPoint], index: 0}];
        running = true;
        executeCurrent();
    }

    private function copyRunHierarchy(): Array<ScriptProcess> {
        var out = new Array<ScriptProcess>();
        for (process in runHierarchy) {
            out.push({command: process.command, index: process.index});
        }
        return out;
    } 

    private function executeCurrent() {
        while (runHierarchy.length > 0 && runHierarchy[0].index == runHierarchy[0].command.commands.length) {
            if (Std.is(runHierarchy[0].command, While)) {
                if (Parser.evaluateExpression(runHierarchy[0].command.condition, variables)) {
                    runHierarchy[0].index = 0;
                } else {
                    runHierarchy.shift();
                }
            } else {
                runHierarchy.shift();
            }
        }
        if (runHierarchy.length == 0) {
            running = false;
            callback();
            return;
        }
        var currentCmd = runHierarchy[0].command.commands[runHierarchy[0].index];
        runHierarchy[0].index++;
        if (Std.is(currentCmd, If)) {
            if (Parser.evaluateExpression(currentCmd.condition, variables) == true) {
                runHierarchy.unshift({command: currentCmd, index: 0});
                executeCurrent();
            } else {
                for (elifCmd in cast(currentCmd, If).elifCmds) {
                    if (Parser.evaluateExpression(elifCmd.condition, variables)) {
                        runHierarchy.unshift({command: elifCmd, index: 0});
                        executeCurrent();
                        return;
                    }
                }

                if (currentCmd.elseCmd != null) {
                    runHierarchy.unshift({command: currentCmd.elseCmd, index: 0});
                    executeCurrent();
                }
            }
        } else if (Std.is(currentCmd, While)) {
            if (Parser.evaluateExpression(currentCmd.condition, variables)) {
                runHierarchy.unshift({command: currentCmd, index: 0});
            }
            executeCurrent();
        } else if (Std.is(currentCmd, RegularEventCall)) {
            var evaluatedArgs = new Array<Dynamic>();
            for (arg in cast(currentCmd.args, Array<Dynamic>)) {
                evaluatedArgs.push(Parser.evaluateExpression(arg, variables));
            }
            var nextCommand = (runHierarchy[0].command.commands.length > runHierarchy[0].index)? runHierarchy[0].command.commands[runHierarchy[0].index]:null;
            switch (currentCmd.event) {
                case "message": messageBox.message(executeCurrent, messageBoxStayOn(copyRunHierarchy(), variables.copy()), evaluatedArgs[0]);
                case "delay": delay.delay(executeCurrent, evaluatedArgs[0], (evaluatedArgs.length > 1)? evaluatedArgs[0]:false);
                case "cameramode": Event.cameraMode(executeCurrent, evaluatedArgs[0]);
                case "camerawalk": cameraWalk.cameraWalk(executeCurrent, evaluatedArgs[0], evaluatedArgs[1], evaluatedArgs[2], (evaluatedArgs.length > 3)? evaluatedArgs[3]:false);
                case "shake": screenShake.screenShake(executeCurrent, evaluatedArgs[0], evaluatedArgs[1], (evaluatedArgs.length > 2)? evaluatedArgs[2]:false, (evaluatedArgs.length > 3)? evaluatedArgs[3]:false);
            }
            //events[currentCmd.event](executeCurrent, evaluatedArgs);
        } else if (Std.is(currentCmd, Menu)) {
            var choices = new Array<String>();
            for (choice in cast(currentCmd, Menu).choices) {
                choices.push(Parser.evaluateExpression(choice.value, variables));
            }
            messageBox.menu(function (choice: Int) {
                runHierarchy.unshift({command: currentCmd.choices[choice], index: 0});
                executeCurrent();
            }, messageBoxStayOn(copyRunHierarchy(), variables.copy()), choices);
        } else if (Std.is(currentCmd, Jump)) {
            runHierarchy.unshift({command: labels[currentCmd.label], index: 0});
            executeCurrent();
        } else if (Std.is(currentCmd, SetVariable)) {
            variables[currentCmd.variable] = Parser.evaluateExpression(currentCmd.value, variables);
            executeCurrent();
        }
    }

    private function messageBoxStayOn(runHierarchy: Array<ScriptProcess>, variables: Map<String, Dynamic>) {
        while (runHierarchy.length > 0 && runHierarchy[0].index == runHierarchy[0].command.commands.length) {
            runHierarchy.shift();
        }
        if (runHierarchy.length == 0) {
            return false;
        }
        var currentCmd = runHierarchy[0].command.commands[runHierarchy[0].index];
        runHierarchy[0].index++;
        if (Std.is(currentCmd, If)) {
            if (Parser.evaluateExpression(currentCmd.condition, variables) == true) {
                runHierarchy.unshift({command: currentCmd, index: 0});
                return messageBoxStayOn(runHierarchy, variables);
            }
            
            for (elifCmd in cast(currentCmd, If).elifCmds) {
                if (Parser.evaluateExpression(elifCmd.condition, variables)) {
                    runHierarchy.unshift({command: elifCmd, index: 0});
                    return messageBoxStayOn(runHierarchy, variables);
                }
            }

            if (currentCmd.elseCmd != null) {
                runHierarchy.unshift({command: currentCmd.elseCmd, index: 0});
                return messageBoxStayOn(runHierarchy, variables);
            }
        } else if (Std.is(currentCmd, While)) {
            if (Parser.evaluateExpression(currentCmd.condition, variables)) {
                runHierarchy.unshift({command: currentCmd, index: 0});
            }
            return messageBoxStayOn(runHierarchy, variables);
        } else if (Std.is(currentCmd, RegularEventCall)) {
            return (currentCmd.event == "message");
        } else if (Std.is(currentCmd, Menu)) {
            return true;
        } else if (Std.is(currentCmd, Jump)) {
            runHierarchy.unshift({command: labels[currentCmd.label], index: 0});
            return messageBoxStayOn(runHierarchy, variables);
        } else if (Std.is(currentCmd, SetVariable)) {
            variables[currentCmd.variable] = Parser.evaluateExpression(currentCmd.value, variables);
            return messageBoxStayOn(runHierarchy, variables);
        }
        return false;
    }
}
// end region