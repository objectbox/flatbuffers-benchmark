# Flatbuffers performance comparison

Resulting operations per second:

| Operation   | Dart (official flat_buffers) | Dart (ObjectBox flat_buffers) | Go  |
|-------------------|-------------------:|-------------------:|-------------------:|
| write FlatBuffers |             12 640 |            420 234 |          6 949 270 |
| read FlatBuffers  |          4 070 902 |          3 733 616 |          9 242 144 |


## Dart

The benchmark_harness executes a 10-call timing loop repeatedly until 2 seconds have elapsed.
The reported result is the average of the runtimes.

```shell
$ pub run benchmark/flatbuffers_official.dart
Builder(RunTime): 791.1043890865955 us.
Reader(RunTime): 2.456457470758959 us.

$ pub run benchmark/flatbuffers_objectbox.dart
Builder(RunTime): 23.796221161968898 us.
Reader(RunTime): 2.6783684467085562 us.
```

## Go

To get (closer) to what Dart does: execute 10 iterations of the same operation for each measured loop.

```shell
$ go test -bench .
goos: linux
goarch: amd64
pkg: flatbuffers_go_benchmark
BenchmarkBuilder-12       820893              1439 ns/op
BenchmarkReader-12       1000000              1082 ns/op
```
