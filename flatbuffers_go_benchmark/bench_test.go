package flatbuffers_go_benchmark

import (
	"github.com/google/flatbuffers/go"
	"github.com/stretchr/testify/assert"

	"testing"
)

func BenchmarkBuilder(b *testing.B) {
	var builder = flatbuffers.NewBuilder(256)
	for i := 0; i < b.N; i++ {
		// execute 10 times to get this benchmark closer to what dart benchmark_harness does
		for j := 0; j < 10; j++ {
			builder.Reset()
			writeData(builder)
		}
	}
}

func BenchmarkReader(b *testing.B) {
	var builder = flatbuffers.NewBuilder(256)
	var data = writeData(builder)

	for i := 0; i < b.N; i++ {
		// execute 10 times to get this benchmark closer to what dart benchmark_harness does
		for j := 0; j < 10; j++ {
			readData(data)
		}
	}
}

func TestRoundtrip(t *testing.T) {
	var builder = flatbuffers.NewBuilder(256)
	var data = writeData(builder)
	var read = readData(data)
	assert.Equal(t, source.number, read.number)
	assert.Equal(t, source.float, read.float)
	assert.Equal(t, source.str, read.str)
	assert.Equal(t, source.bytes, read.bytes)
}

type POD struct {
	number int64
	float  float64
	str    string
	bytes  []byte // int to keep the type close to dart benchmark
}

var source = POD{
	number: 1,
	float:  4.2,
	str:    "Foo",
	bytes:  []byte{1, 2, 3, 4, 5, 6},
}

func writeData(builder *flatbuffers.Builder) []byte {
	var strOffset = builder.CreateString(source.str)
	var bytesOffset = builder.CreateByteVector(source.bytes)
	builder.StartObject(4)
	builder.PrependInt64(source.number)
	builder.Slot(0)
	builder.PrependFloat64(source.float)
	builder.Slot(1)
	builder.PrependUOffsetT(strOffset)
	builder.Slot(2)
	builder.PrependUOffsetT(bytesOffset)
	builder.Slot(3)
	builder.Finish(builder.EndObject())
	return builder.FinishedBytes()
}

func field(slot int) flatbuffers.VOffsetT {
	return flatbuffers.VOffsetT(slot*2 + 4)
}

func readData(data []byte) *POD {
	var table = flatbuffers.Table{
		Bytes: data,
		Pos:   flatbuffers.GetUOffsetT(data),
	}

	var object = &POD{}
	object.number = table.GetInt64Slot(field(0), 0)
	object.float = table.GetFloat64Slot(field(1), 0)
	if o := table.Offset(field(2)); o != 0 {
		object.str = table.String(flatbuffers.UOffsetT(o) + table.Pos)
	}
	if o := table.Offset(field(3)); o != 0 {
		object.bytes = table.ByteVector(flatbuffers.UOffsetT(o) + table.Pos)
	}
	return object
}
