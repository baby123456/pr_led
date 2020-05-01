open_project /home/free/workspace/serve/fpga/vivado_prj/serve_s/serve_s.xpr

# 部分可重构模块（初始role）的综合，此处模块名为TLPRBox，必须使用OOC模式
synth_design -top TLPRBox -mode out_of_context
# synth_rp.dcp保存部分可重构模块综合结果
write_checkpoint /home/free/tlpr/synth-rp.dcp -force

# 替换文件，非必须
remove_files freedom.v
add_files /home/free/workspace/serve/hw_plat/freedom-static.v
set_property top serve_s_wrapper [current_fileset]
update_compile_order -fileset [current_fileset]

# 综合shell，TLPRBox模块必须是blackbox
synth_design -top serve_s_wrapper
# synth_static保存shell综合结果
write_checkpoint /home/free/tlpr/synth-static.dcp -force

#remove_files freedom-static.v
#read_verilog /home/free/workspace/serve/hw_plat/freedom.v
#update_compile_order

# 当前design仍为shell，不必再打开dcp
#open_checkpoint /home/free/tlpr/synth-static.dcp

# tlpr是TLPRBox在顶层中的实例化名称，为tlpr设置可重构属性
set_property HD.RECONFIGURABLE true [get_cells -hierarchical tlpr]

# 将TLPRBox综合结果加载到当前shell中
read_checkpoint -cell [get_cells -hierarchical tlpr] /home/free/tlpr/synth-rp.dcp

# 划分Pblock，划分位置没有明确标准
create_pblock tlpr_pblock
resize_pblock tlpr_pblock -add {SLICE_X29Y150:SLICE_X48Y179 DSP48E2_X3Y60:DSP48E2_X4Y71 RAMB18_X3Y60:RAMB18_X5Y71 RAMB36_X3Y30:RAMB36_X5Y35}
# 将tlpr放到Pblock里
add_cells_to_pblock tlpr_pblock [get_cells -hierarchical tlpr] -clear_locs

# 正常流程
opt_design
place_design
phys_opt_design
route_design

# route-full.dcp保存shell和初始role的布线结果
write_checkpoint /home/free/tlpr/route-full.dcp -force
# route-rp.dcp保存初始role的布线结果
write_checkpoint -cell [get_cells -hierarchical tlpr] /home/free/tlpr/route-rp.dcp -force
# 包含shell和初始role的bitstream，-no_partial_bitfile表示不生成单独的partial bitstream
write_bitstream -no_partial_bitfile /home/free/workspace/serve/hw_plat/system.bit -force

# 将布线结果中的tlpr替换为blackbox
update_design -cell [get_cells -hierarchical tlpr] -black_box 
# 锁定布线结果
lock_design -level routing
# route-static.dcp保存shell的布线结果，供后续role布局布线使用
write_checkpoint /home/free/tlpr/route-static.dcp -force
