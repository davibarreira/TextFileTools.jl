# Functions for inserting text are based on
# https://discourse.julialang.org/t/write-to-a-particular-line-in-a-file/50179

module TextFileTools
using ReadableRegex

export writetext, insertline


"""
    skiplines(io::IO, n)
Helper function for skipping lines when reading a file.
"""
function skiplines(io::IO, n)
    i = 1
    while i <= n
        eof(io) && error("File contains less than $(n + 1) lines")
        i += read(io, Char) === '\n'
    end
end


"""
    writetext(file::String, text::String, linenumber::Integer, at=Inf)
Writes a `text` to a `file` in an specific `linenumber` and `at` an specific location.
By default, the text is appended at the end of the line (`at = Inf`). If
`at = 1`, then the text is actually appended in the beggining of the line.
You might also want to add it to an specific position, e.g.
`at = 2`, which will append the text after the first `Char`.
"""
function writetext(file::String, text::String, linenumber::Integer; at=Inf)
    f = open(file, "r+");
    if at == Inf
        skiplines(f, linenumber);
        skip(f, -1)
    else
        skiplines(f, linenumber - 1);
        skip
    end
    mark(f)
    buf = IOBuffer()
    write(buf, f)
    seekstart(buf)
    reset(f)
    print(f, text);
    write(f, buf)
    close(f)
end

"""
    writetext(file::String, text::String, linenumber=:last; at=Inf)
Writes text to the last line.
"""
function writetext(file::String, text::String, linenumber=:last; at=Inf)
    @assert linenumber == :last
    if at == Inf
        open(file, "a+") do f
            write(f, text)
        end
    else
        # !!This is not efficient. Should be improved
        writetext(file, text, countlines(file), at=at)
    end
end

"""
    insertline(file::String, text::String, linenumber::Integer; position=:above)
Inserts a line of `text` in a `file` at the specified `linenumber`.
Accepts `position=:above` (default), `position=:below` or `position=:replace`, to specify
whether the text will be placed above, below or replace the current line.
**Important**, if you want to add a line at the end of the file (after the last line),
use `insertline(file::String, text::String, :lasts)` instead.
Here is an example,
consider a text file containing:

```
Text file example
Current text it here
```

Hence, after running `insertline("textfile.txt", "!insert this", 2)`,
you will get
```
Text file example
!insert this
Current text it here
```
"""
function insertline(file::String, text::String, linenumber::Integer; position=:above)
    if position == :above
        insertlineabove(file, text, linenumber)
    elseif position == :below
        insertlinebelow(file, text, linenumber)
    else
        throw(ArgumentError("Invalid position. Use either `position=:above` or `position=:below`."))
    end
end

"""
    insertline(file::String, text::String, linenumber=:last; position=:above)
Inserts line in the last line of the file.
"""
function insertline(file::String, text::String, linenumber=:last; position=:below)
    @assert linenumber == :last
    if position == :above
        insertlineabove(file, text, countlines(file))
    elseif position == :below
        open(file, "a+") do f
            write(f, "\n" * text)
        end
    else
        throw(ArgumentError("Invalid position. Use either `position=:above` or `position=:below`."))
    end
end

"""
    insertlineabove(file::String, text::String, linenumber::Integer)
Inserts a line of `text` in a `file` above the `linenumber`.
"""
function insertlineabove(file::String, text::String, linenumber::Integer)
    if linenumber == 1
        writetext(file, text * "\n", linenumber, at=1)
    else
        writetext(file, "\n" * text, linenumber - 1, at=Inf)
    end
end

"""
    insertlinebelow(file::String, text::String, linenumber::Integer)
Inserts a line of `text` in a `file` below the `linenumber`.
This does not work if the linenumber is the last line. Look
`function insertline(file::String, text::String, linenumber=:last; position=:below)`
instead.
"""
function insertlinebelow(file::String, text::String, linenumber::Integer)
    writetext(file, "\n" * text, linenumber, at=Inf)
end

"""
    insertlinereplace(file::String, text::String, linenumber::Integer)
Inserts a line of `text` in a `file` replacing the current line.
"""
function insertlinereplace(file::String, text::String, linenumber::Integer)
    writetext(file, "\n" * text, linenumber)
end

"""
    insertlineforce(file::String, text::String, linenumber::Integer)
Inserts a line of `text` in a `file` below the `linenumber`.
"""
function insertemptylines(file::String, text::String, qtd::Integer)
    writetext(file, "\n" * text, linenumber)
end


end
