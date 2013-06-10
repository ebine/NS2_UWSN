set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

set nn 8

set nf [open result/out.nam w]
#$ns use-newtrace
$ns namtrace-all $nf

set nd [open result/out.tr w]
$ns use-newtrace
$ns trace-all $nd

proc finish {} {
        global ns nf nd
        $ns flush-trace
        close $nf
        close $nd 
        exec nam result/out.nam &
        exit 0
}

#routing protocol
$ns rtproto DV

set rng [new RNG]
$rng seed 997
set RVposition [new RandomVariable/Uniform]
$RVposition use-rng $rng
$RVposition set min_ 0.0
$RVposition set max_ 500.0
#$RVposition use-rng $rng

#set god_ [create-god &val(nn)]
for {set i 0} {$i < $nn} {incr i} {
	set node_($i) [$ns node]
	$node_($i) set Y_ [$RVposition value]
	$node_($i) set X_ [$RVposition value]
	$node_($i) set Z_ 0.0
	set tmp_x [$node_($i) set X_]
	set tmp_y [$node_($i) set Y_]
	set tmp_z [$node_($i) set Z_]
	puts $nd "node_($i): $tmp_x\t$tmp_y\t$tmp_z\n"
	
	#set nodex($i) [$RVposition value]
	#set nodey($i) [$RVposition value]
	#$node_($i) random-motion 0

}

#for {set i 0} {$i < $nn} {incr i} {
	#set node_($i) [$ns node]
	#$node_($i) set Y_ $nodey($i)
	#$node_($i) set X_ $nodex($i)
	#$node_($i) set Z_ 0.0
	#puts [$RVposition value]
	#$node_($i) random-motion 0

#}


puts "Loading connection pattern ..."

#source test

# Define links
#
$ns duplex-link $node_(2) $node_(1) 1Mb 10ms DropTail
$ns duplex-link $node_(4) $node_(3) 1Mb 10ms DropTail
$ns duplex-link $node_(1) $node_(2) 1Mb 10ms DropTail
$ns duplex-link $node_(2) $node_(3) 1Mb 10ms DropTail
$ns duplex-link $node_(2) $node_(5) 1Mb 10ms DropTail
$ns duplex-link $node_(3) $node_(4) 1Mb 10ms DropTail
$ns duplex-link $node_(4) $node_(5) 1Mb 10ms DropTail
$ns duplex-link $node_(4) $node_(7) 1Mb 10ms DropTail
$ns duplex-link $node_(5) $node_(6) 1Mb 10ms DropTail
$ns duplex-link $node_(6) $node_(7) 1Mb 10ms DropTail


#node_(0) to node_(7)
set udp0 [new Agent/UDP]
$ns attach-agent $node_(1) $udp0
$udp0 set fid_ 1

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set type_ CBR

#Define cbr
$cbr0 set packet_size_ 500
#$cbr0 set rate_ 800Kb
$cbr0 set interval_ 0.005
$cbr0 set random_ false

set null0 [new Agent/Null]
$ns attach-agent $node_(7) $null0
$ns connect $udp0 $null0

#events
#Schedule events for the CBR agents
$ns at 0.5 "$cbr0 start"
#$ns at 0.5 "$cbr1 start"
#$ns at 4.5 "$cbr1 stop"
$ns at 4.5 "$cbr0 stop"

$ns at 5.0 "finish"

$ns run
