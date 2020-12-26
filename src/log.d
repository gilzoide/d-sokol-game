debug 
{
    version (D_BetterC) {}
    else
    {
        version = LogEnabled;
    }
}

struct Log
{
    static void info(Args...)(auto ref Args args)
    {
        version (LogEnabled)
        {
            import std.stdio;
            writeln(args);
        }
    }
}
