# Flatbuffers performance comparison

Note: Reading a list from flatbuffers in Dart requires a copy, resulting in quite a poor performance,
so we measure a separate run with and without doing so.
To be fair/have the numbers for comparison, we do the same in Go, though it doesn't have ssuch a big difference there.

Measured performance is in "operations per second".

## Without byte lists

| Operation         | Dart (official FB) | Dart (ObjectBox FB) | Go                 |
|-------------------|-------------------:|--------------------:|-------------------:|
| write FlatBuffers |             13 060 |             677 673 |          7 806 401 |
| read FlatBuffers  |          8 197 200 |           8 303 290 |          9 920 634 |

## With byte lists

| Operation         | Dart (official FB) | Dart (ObjectBox FB) | Go                 |
|-------------------|-------------------:|--------------------:|-------------------:|
| write FlatBuffers |             12 178 |             451 709 |          7 032 348 |
| read FlatBuffers  |          3 831 742 |           3 883 763 |          8 438 818 |

## Dart

The benchmark_harness executes a 10-call timing loop repeatedly until 2 seconds have elapsed.
The reported result is the average of the runtimes.

```shell
$ pub run benchmark/flatbuffers_official.dart
Measuring performance without byte list
Builder(RunTime): 765.6720244929201 us.
Reader(RunTime): 1.2199287561606402 us.
Measuring performance with byte list
Builder(RunTime): 821.0898645876077 us.
Reader(RunTime): 2.6097788216872186 us.

$ pub run benchmark/flatbuffers_objectbox.dart
Measuring performance without byte list
Builder(RunTime): 14.75636513873826 us.
Reader(RunTime): 1.2043418933940644 us.
Measuring performance with byte list
Builder(RunTime): 22.138108520953708 us.
Reader(RunTime): 2.5748223695305974 us.
```

## Go

To get (closer) to what Dart does: execute 10 iterations of the same operation for each measured loop.

```shell
$ go test -bench .
goos: linux
goarch: amd64
pkg: flatbuffers_go_benchmark
BenchmarkBuilderWithoutBytesList-12       928960              1281 ns/op
BenchmarkReaderWithoutBytesList-12       1226929              1008 ns/op
BenchmarkBuilderWithBytesList-12          819072              1422 ns/op
BenchmarkReaderWithBytesList-12          1000000              1185 ns/op
```
