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

### Notes

- Allocator stuff doesn't seem that hard, but I don't get how you can avoid having some boilerplate
  to deal with them, or at least avoid having to pass them to functions.

- Why is a `bufferedReader` so much better?

- What's the difference between `ArrayList.{clearAndFree,clearRetainingCapacity}`? Why is the
latter 5x faster?
