# Advent of Code (Zig edition)

Let's give the Ziguana a chance!

To run simply [get Zig from their downloads page](https://ziglang.org/download/) then run

```sh
zig run dayX.zig
```

to run __blazingly fast__, execute

```sh
zig build-exe dayX.zig -fsingle-threaded -fstrip -O ReleaseFast && ./dayX
```

## Day 1

So, as with every other AoC, the first real challenge is reading the input data.

After spending some time on [ziglearn](https://ziglearn.org) I found out about [`std.io.Reader`](https://ziglearn.org/chapter-2/#readers-and-writers), but passing in a constant buffer to keep reading chunks didn't sound quite right.

So on I went to find out how you could read a file line by line, of course, that's the perfect
abstraction, and I won't settle for less.
[Karl Seguin's performance analysis of reading a file line by line](https://www.openmymind.net/Performance-of-reading-a-file-line-by-line-in-Zig/) was
an excellent find that actually contains some helpful code, and he even has a utils library
(but importing in Zig is another rabbit hole).

Spent some time trying to make a nice abstraction around a buffered line reader but it's definitely
a little more complex than I hoped for.

I only noticed that you [can't simply avoid touching files to deal with IO](./hello_world.zig) after I had already got
my hands dirty with `bufferedReader`s and `ArrayList`s.
But... that's actually a lie.
You can get away with a cool trick of [embedding the input file in the final binary](https://xyquadrat.ch/2021/12/01/reading-files-in-zig/) by simply doing:

```zig
const data = @embedFile("day1.in")
```

Then `std.mem.tokenizeAny` that to get an iterator and you're golden.

Dumb python version where I try to solve both challenges at once was actually a kind of a pain to
get right.
Obviously performance doesn't even compare.

Glad to see that dealing with optional types is quite similar to Python, with slightly clearer
syntax (?)

Something to note is that [`ArrayList.clearAndFree`](https://ziglang.org/documentation/master/std/#A;std:ArrayList.clearAndFree) being
dramatically slower than [`.clearRetainingCapacity`](https://ziglang.org/documentation/master/std/#A;std:ArrayList.clearRetainingCapacity), which is sad because I wanted to type less...
Now, why is it slower? I hear you ask. Well that's easy, just look at the source code on the
links above.
If you're too lazy, `.clearRetainingCapacity` simply won't free anything, you just reset the
capacity so that you allocate new memory.
But now do we actually have a leak? I don't really care, but it could even make some memory
management simpler (see `.toOwnedSlice()` on day 3).

## Day 2

Calculating the set power of struct fields was the real challenge here, because I wanted something
that'd capture our assertions about the field types, while maintaining the flexibility of having
arbitrarily many colored cubes in our game.

Using comptime to set the max proved very inefficient, so that leads me to wonder if calculating
set power directly wouldn't also help.

Of course using a small buffer on the stack would be better, and getting from stdin seems to have a
BIG performance penalty too.

Got a performance boost by simply taking out some comptime to avoid needless abstraction.
Simply using an array for the cubes was obvious, but I also wanted an API that guaranteed accesses
correspond to the expected enum (does that make sense? lol).
So I'm thinking of using comptime to generate a type that intertwines the user's enum for the game
cube colors and also provides a size, then we abstract every operation to deal with N cubes of a
rainbow of colors and everyone is happy.
And of course I'm only pondering that because I want to see what comptime is capable of.

## Day 3

Got a bit lost when trying to deal with simple memory management in Zig, so I decided I try doing a
python version first.
This wasn't an easy puzzle, but it also didn't take much after figuring out that no number touches
more than one symbol, so it was actually possible to get part numbers by checking around symbols.
Finally got to use some regex to make my life easier, but I didn't realize `re.search` doesn't
return all matches on the line...

I won the Ziguana at last, but I'm also more sure than ever that memory is a weird thing.
Would never have guessed that I could simply use my trusty gpa to copy an array, which is quite
handy, but I don't get if I ever have to free that.
Also tried to use `ArrayList.toOwnedSlice()`, but haven't measured performance for that yet.
I think it'd be interesting to try using the same scanline idea for getting part numbers, but I'm
too tired to try that now.
BTW it's definitely not the best variable naming ever.

## Day 4

Nothing too complex today, but I wish I could use a queue for that.
There seems to be no way of simply updating a value on the queue by its index, so an ArrayList
seemed more practical but we could definitely get away with fixed-size buffers.
Maybe I'll try that later.
Either way this one is __already__ blazingly fast (~400us on the M1 🔥).

The answer, of course, always lies in group theory.
Joking aside, I should probably make better benchmarks, but coding something to generate inputs is
a little beyond my scope, and I'm already spending too much time on these.

## Notes

- Allocator stuff doesn't seem that hard, but I don't get how you can avoid having some boilerplate
  to deal with them, or at least avoid having to pass them to functions.

- What's the better way of asserting a type in comptime?
