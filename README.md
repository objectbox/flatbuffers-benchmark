# FlatBuffers performance comparison

This repository comes with benchmarking code for different FlatBuffer implementations across programing languages.

## Setup

* Measured performance is in "operations per second".
* Benchmarks are CPU bound (no disk operations).
* Executed on a laptop CPU: Intel Core i7-8850H
* Dart uses JIT unless AOT is indicated.
* Dart benchmark_harness executes a 10-call timing loop repeatedly until 2 seconds have elapsed.
  The reported result is the average of the runtimes.

## Results 

|     Date   | Variant                         |       Read |      Write |  Read (w.bytes) | Write (w.bytes) |
|:----------:|---------------------------------|-----------:|-----------:|----------------:|----------------:|
| 2021-02-26 | Dart official FB v0.12          |  8 197 200 |     13 060 |       3 831 742 |          12 178 |
| 2021-02-26 | Dart official FB master         |  8 878 415 |  3 284 045 |       4 032 722 |       2 592 991 |
| 2021-02-26 | Dart ObjectBox v0.12 FB         |  9 074 660 |  5 044 802 |       4 732 340 |       4 212 460 |
| 2021-02-26 | Dart AOT ObjectBox v0.12 FB     |  8 149 270 |  3 821 181 |       5 020 220 |       3 189 186 |
| 2021-02-26 | Go                              |  9 920 634 |  7 806 401 |       8 438 818 |       7 032 348 |

Note about results with a byte list: when reading a list from FlatBuffers in Dart, we call toList() to complete detach 
from the buffer (do not reference data inside the buffer). To be fair/have the numbers for comparison, we do the same in
Go, though it doesn't have such a big impact there.

### Benchmarked on 2021-02-26

* Dart SDK v2.10.5 (FlatBuffers)
* Dart SDK v2.12.0 (ObjectBox FlatBuffers)
* Dart flat_buffers v1.12.0
* Dart flat_buffers master (as of 2012-02-26) with some performance-related PRs we've got merged upstream
* Dart objectbox/flatbuffers fork - from objectbox-dart v0.12.0
* Go version go1.15.8
* Go flatbuffers v1.12.0

#### Dart JIT

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
Builder(RunTime): 1.9822381638140623 us.
Reader(RunTime): 1.1019696605713052 us.
Measuring performance with byte list
Builder(RunTime): 2.3739097819326473 us.
Reader(RunTime): 2.113119513813462 us.
```

#### Dart AOT

We measured only the fastest variant (ObjectBox fork):

```shell
$ dart2native benchmark/flatbuffers_objectbox.dart --output bench && ./bench
Generated: /flatbuffers_benchmark/flatbuffers_dart_benchmark/bench
Measuring performance without byte list
Builder(RunTime): 2.616991849387036 us.
Reader(RunTime): 1.227103777393558 us.
Measuring performance with byte list
Builder(RunTime): 3.1355955587468918 us.
Reader(RunTime): 1.9919445761341137 us.
```

#### Go plain results

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
