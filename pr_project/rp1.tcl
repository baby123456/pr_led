open_project /home/free/workspace/serve/fpga/vivado_prj/serve_s/serve_s.xpr

# 综合第一个可替换role，此处同full.tcl
synth_design -top TLPRBox -mode out_of_context
write_checkpoint /home/free/tlpr/synth-rp1.dcp -force

# 加载shell布线结果
open_checkpoint /home/free/tlpr/route-static.dcp
# 加载第一个可替换role的综合结果到shell中
read_checkpoint -cell [get_cells -hierarchical tlpr] /home/free/tlpr/synth-rp1.dcp

# 正常流程，此处只对role布局布线，shell已被锁定
opt_design
place_design
phys_opt_design
route_design

# 第一个可替换role的dcp和partial bitstream
write_checkpoint -cell [get_cells -hierarchical tlpr] /home/free/tlpr/route-rp1.dcp -force
write_bitstream -cell [get_cells -hierarchical tlpr] /home/free/tlpr/rp1.bit -force
