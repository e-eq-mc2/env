require 'find'
require 'awesome_print'
require 'pry-byebug'

BS_K = [
  4,
  8,
  16,
  32,
  64,
  128,
  256,
  512,
]

MODE = [
  'sequential-read',
  'sequential-write',
  'sequential-readwrite',
  'random-readwrite',
]

def to_byte(val, unit)
  factor = 
    case unit.upcase
    when "B"  then 2 ** 0 
    when "KB" then 2 ** 10
    when "MB" then 2 ** 20
    when "GB" then 2 ** 30
    else fail
    end

  val * factor
end

def fio_info(file)
  File.foreach(file) do |line|
    if line =~ /: \(\w+=\w+\): rw=(\w+), bs=(\w+)-(\w+)\/(\w+)-(\w+)\/(\w+)-(\w+),/
      mode = $~[1]
      bs   = $~[2]
      res = {
        mode: mode,
        bs:   bs,
      }
      return res
    end
  end
  nil
end

def parse(file)
  result = {}
  File.foreach(file) do |line|
    if line =~ /(read|write)\s*: io=([\d.]+)(B|KB|MB|GB), bw=([\d.]+)(B|KB|MB|GB)\/s, iops=(\d+),/
      type    =  $~[1] || fail
      io      = ($~[2]|| fial).to_i
      io_unit =  $~[3] || fail
      bw      = ($~[4] || fail).to_i 
      bw_unit =  $~[5] || fail
      iops    = ($~[6] || fail).to_i

      result[type] = {
        type: type,
        io:   to_byte(io, io_unit),
        bw:   to_byte(bw, bw_unit),
        iops: iops,
      }
    end
  end
  result
end

def aggregate(result, key)
  r = result["read" ] ? result["read" ][key] : 0
  w = result["write"] ? result["write"][key] : 0
  r + w
end

dirbase = ARGV[0]

result = {}
MODE.each do |mode|
  BS_K.each do |bs|
    path = File.join dirbase, "#{bs}k", "#{mode}.txt"

    res = parse(path)
    result[mode] = {} if result[mode].nil?
    result[mode][bs] = res
  end
end

result.each do |mode, res_per_mode|
  puts "----#{mode}----"
  res_per_mode.each do |bs, res_per_bs|
    agg_bw   = aggregate(res_per_bs, :bw  )
    agg_iops = aggregate(res_per_bs, :iops)

    print "bs=#{bs}k, aggregate, #{agg_bw / 1024 / 1024} MB/s, #{agg_iops} IOPS, "
    puts

    res_per_bs.each do |type, res|
      type = res[:type]
      io   = res[:io  ]
      bw   = res[:bw  ]
      iops = res[:iops]

      print "  #{type}, #{bw / 1024 / 1024} MB/s, #{iops} IOPS, "
      puts
    end
    puts
  end
end
