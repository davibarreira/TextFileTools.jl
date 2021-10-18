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
        eof(io) && error("File contains less than $n lines")
        i += read(io, Char) === '\n'
    end
end

"""
    countlines(file::String)
Returns the number of lines in a file.
"""
function countlines(file::String; limit=10_000)
    io = open(file, "r");
    i = 0
    while i <= limit
        if eof(io)
            break
        end
        i += read(io, Char) === '\n'
    end
    close(io)
    return i
end


"""
    writetext(file::String, text::String, linenumber::Integer, at=Inf)
Writes a `text` to a `file` in an specific `linenumber` and `at` an specific location.
By default, the text is appended at the end of the line (`at = Inf`). If
`at = 1`, then the text is actually appended in the beggining of the line.
You might also want to add it to an specific position, e.g.
`at = 2`, which will append the text after the first `Char`.
"""
function writetext(file::String, text::String, linenumber::Integer, at=Inf)
    f = open(file, "r+");
    if at == Inf
        skiplines(f, linenumber);
        skip(f, -1)
    else
        skiplines(f, linenumber - 1);
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
    writetext(file::String, text::String, linenumber::Integer, endline=true)
"""
function writetext(file::String, text::String, linenumber=:last; at=Inf)
    writetext(file, text, countlines(file), at=at)
end

"""
    insertline(file::String, text::String, linenumber::Integer; method=:above)
Inserts a line of `text` in a `file` at the specified `linenumber`.
Accepts `method=:above` (default), `method=:below` or `method=:replace`, to specify
whether the text will be placed above, below or replace the current line.
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
function insertline(file::String, text::String, linenumber::Integer; method=:above)
    if method == :above
        insertlineabove(file, text, linenumber)
    elseif method == :below
        insertlinebelow(file, text, linenumber)
    else
        throw(ArgumentError("Invalid method. Use either `method=:above` or `method=:below`."))
    end
end

function insertline(file::String, text::String, linenumber=:last; method=:below)
    @assert linenumber == :last
    if method == :above
        insertlineabove(file, text, countlines(file))
    elseif method == :below
        insertlinebelow(file, text, countlines(file))
    else
        throw(ArgumentError("Invalid method. Use either `method=:above` or `method=:below`."))
    end
end

"""
    insertlineabove(file::String, text::String, linenumber::Integer)
Inserts a line of `text` in a `file` above the `linenumber`.
"""
function insertlineabove(file::String, text::String, linenumber::Integer)
    if linenumber == 1
        writetext(file, text * "\n", linenumber, 1)
    else
        writetext(file, "\n" * text, linenumber - 1, Inf)
    end
end

"""
    insertlinebelow(file::String, text::String, linenumber::Integer)
Inserts a line of `text` in a `file` below the `linenumber`.
"""
function insertlinebelow(file::String, text::String, linenumber::Integer)
    writetext(file, "\n" * text, linenumber, Inf)
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
