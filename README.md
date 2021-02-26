# Flatbuffers performance comparison

Note: Reading a list from flatbuffers in Dart requires a copy, resulting in quite a poor performance,
so we measure a separate run with and without doing so.
To be fair/have the numbers for comparison, we do the same in Go, though it doesn't have such a big impact there.

Measured performance is in "operations per second".

### Versions

* Dart SDK v2.10.5
* Dart flat_buffers v1.12.0
* Dart flat_buffers master (as of 2012-02-26) with some performance-related PRs we've got merged upstream
* Dart objectbox/flatbuffers fork - from objectbox-dart v0.12.0
* Go version go1.15.8
* Go flatbuffers v1.12.0

## Without byte lists

| Operation         | Dart (official FB v0.12) | Dart (official FB master) | Dart (ObjectBox FB) | Go                 |
|-------------------|-------------------------:|--------------------------:|--------------------:|-------------------:|
| write FlatBuffers |                   13 060 |                 3 284 045 |           3 319 266 |          7 806 401 |
| read FlatBuffers  |                8 197 200 |                 8 878 415 |           9 118 250 |          9 920 634 |

## With byte lists

| Operation         | Dart (official FB v0.12) | Dart (official FB master) | Dart (ObjectBox FB) | Go                 |
|-------------------|-------------------------:|--------------------------:|--------------------:|-------------------:|
| write FlatBuffers |                   12 178 |                 2 592 991 |           2 641 273 |          7 032 348 |
| read FlatBuffers  |                3 831 742 |                 4 032 722 |           4 905 760 |          8 438 818 |

## Dart

The benchmark_harness executes a 10-call timing loop repeatedly until 2 seconds have elapsed.
The reported result is the average of the runtimes.

```shell
# v0.12
$ pub run benchmark/flatbuffers_official.dart 
Measuring performance without byte list
Builder(RunTime): 765.6720244929201 us.
Reader(RunTime): 1.2199287561606402 us.
Measuring performance with byte list
Builder(RunTime): 821.0898645876077 us.
Reader(RunTime): 2.6097788216872186 us.

# master
$ pub run benchmark/flatbuffers_official.dart 
Measuring performance without byte list
Builder(RunTime): 3.0450252660971455 us.
Reader(RunTime): 1.1263271653780544 us.
Measuring performance with byte list
Builder(RunTime): 3.856550051195625 us.
Reader(RunTime): 2.4797140891084815 us.

$ pub run benchmark/flatbuffers_objectbox.dart 
Measuring performance without byte list
Builder(RunTime): 3.0127136388422757 us.
Reader(RunTime): 1.096701669728292 us.
Measuring performance with byte list
Builder(RunTime): 3.7860521907033533 us.
Reader(RunTime): 2.038420103694327 us.
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
