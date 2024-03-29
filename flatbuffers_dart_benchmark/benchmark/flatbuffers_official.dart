import 'dart:typed_data';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flat_buffers/flat_buffers.dart' as fb;

var withBytesList = true;

// Note: the benchmark_harness executes a 10-call timing loop repeatedly until
// 2 seconds have elapsed; the reported result is the average of the runtimes.
void main() {
  ReaderBench.test();

  print('Measuring performance without byte list');
  withBytesList = false;
  BuilderBench.main();
  ReaderBench.main();

  print('Measuring performance with byte list');
  withBytesList = true;
  BuilderBench.main();
  ReaderBench.main();
}

class POD {
  int number;
  double float;
  String string;
  List<int>? bytes;

  POD(this.number, this.float, this.string, this.bytes);
}

final source = POD(1, 4.2, 'Foo', [1, 2, 3, 4, 5, 6]);

Uint8List writeData(fb.Builder builder) {
  final strOffset = builder.writeString(source.string, asciiOptimization: true);
  var bytesOffset = 0;
  if (withBytesList) bytesOffset = builder.writeListInt8(source.bytes!);
  builder.startTable(withBytesList ? 4 : 3);
  builder.addInt64(0, source.number);
  builder.addFloat64(1, source.float);
  builder.addOffset(2, strOffset);
  if (withBytesList) builder.addOffset(3, bytesOffset);
  builder.finish(builder.endTable());
  return builder.buffer;
}

class BuilderBench extends BenchmarkBase {
  final builder = fb.Builder(initialSize: 256, deduplicateTables: false);

  BuilderBench() : super('Builder');

  static void main() => BuilderBench().report();

  // The benchmark code.
  @override
  void run() {
    builder.reset();
    writeData(builder);
  }

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {}

  // Not measures teardown code executed after the benchmark runs.
  @override
  void teardown() {}
}

class ReaderBench extends BenchmarkBase {
  var data = Uint8List(0);

  ReaderBench() : super('Reader');

  static void main() => ReaderBench().report();

  /// Roundtrip test source->FB->read (== source)
  static void test() {
    final bench = ReaderBench();
    bench.setup();
    final read = bench.readData();
    bench.teardown();

    assert(read.number == source.number);
    assert(read.float == source.float);
    assert(read.string == source.string);
    if (withBytesList) {
      assert(read.bytes!.length == source.bytes!.length);
      for (var i = 0; i < read.bytes!.length; i++) {
        assert(read.bytes![i] == source.bytes![i]);
      }
    }
  }

  // The benchmark code.
  @override
  void run() => readData();

  POD readData() {
    final buffer = fb.BufferContext.fromBytes(data);
    final rootOffset = buffer.derefObject(0);

    return POD(
        const fb.Int64Reader().vTableGet(buffer, rootOffset, field(0), 0),
        const fb.Float64Reader().vTableGet(buffer, rootOffset, field(1), 0),
        const fb.StringReader().vTableGet(buffer, rootOffset, field(2), ''),
        withBytesList
            ? const fb.Int8ListReader(lazy: false)
                .vTableGetNullable(buffer, rootOffset, field(3))
            : null);
  }

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    final builder = fb.Builder();
    data = writeData(builder);
  }

  // Not measures teardown code executed after the benchmark runs.
  @override
  void teardown() {}

  @pragma('vm:prefer-inline')
  int field(int slot) => slot * 2 + 4;
}
