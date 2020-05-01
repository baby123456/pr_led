open_project /home/ict/pr_led/pr_project/pr_led/pr_led.xpr
# 综合第一个可替换role，此处同full.tcl
synth_design -top shift -mode out_of_context
write_checkpoint /home/ict/pr_led/pr_project/led/synth-rp1.dcp -force

# 加载shell布线结果
open_checkpoint /home/ict/pr_led/pr_project/led/route-static.dcp
# 加载第一个可替换role的综合结果到shell中
read_checkpoint -cell [get_cells -hierarchical inst_shift_low] /home/ict/pr_led/pr_project/led/synth-rp1.dcp
read_checkpoint -cell [get_cells -hierarchical inst_shift_high] /home/ict/pr_led/pr_project/led/synth-rp1.dcp
# 正常流程，此处只对role布局布线，shell已被锁定
opt_design
place_design
phys_opt_design
route_design

# 第一个可替换role的dcp和partial bitstream
write_checkpoint -cell [get_cells -hierarchical inst_shift_low] /home/ict/pr_led/pr_project/led/inst_shift_low_rp1.dcp -force
write_bitstream -cell [get_cells -hierarchical inst_shift_low] /home/ict/pr_led/hw_plat/inst_shift_low_rp1.bit -force

write_checkpoint -cell [get_cells -hierarchical inst_shift_high] /home/ict/pr_led/pr_project/led/inst_shift_high_rp1.dcp -force
write_bitstream -cell [get_cells -hierarchical inst_shift_high] /home/ict/pr_led/hw_plat/inst_shift_high_rp1.bit -force

