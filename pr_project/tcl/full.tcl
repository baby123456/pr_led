# project name
set project_name pr_led
	
# device and board
set device xczu2eg-sfva625-1-e
set board interwiser:none:part0:2.0

# setting up the project
create_project ${project_name} -force -dir "./${project_name}" -part ${device}
set_property board_part ${board} [current_project]

# add source files	
add_files -norecurse -fileset sources_1 /home/ict/pr_led/pr_project/Sources/hdl/shift_left
add_files -norecurse -fileset sources_1 /home/ict/pr_led/pr_project/Sources/hdl/top
add_files -norecurse -fileset sources_1 /home/ict/pr_led/pr_project/Sources/xdc/pblocks_interwiser.xdc
#open_project /home/ict/pr_led/pr_project/pr_led/pr_led.xpr

# 部分可重构模块（初始role）的综合，此处模块名为shift，必须使用OOC模式
synth_design -top shift -mode out_of_context
# synth_rp.dcp保存部分可重构模块综合结果
write_checkpoint /home/ict/pr_led/pr_project/led/synth-rp.dcp -force

# 综合shell，TLPRBox模块必须是blackbox
synth_design -top top
# synth_static保存shell综合结果
write_checkpoint /home/ict/pr_led/pr_project/led/synth-static.dcp -force

# inst_shift_low是shift在顶层中的实例化名称，为inst_shift_low设置可重构属性
set_property HD.RECONFIGURABLE true [get_cells -hierarchical inst_shift_low]
set_property HD.RECONFIGURABLE true [get_cells -hierarchical inst_shift_high]

# 将shift综合结果加载到当前shell中
read_checkpoint -cell [get_cells -hierarchical inst_shift_low] /home/ict/pr_led/pr_project/led/synth-rp.dcp
read_checkpoint -cell [get_cells -hierarchical inst_shift_high] /home/ict/pr_led/pr_project/led/synth-rp.dcp
# 划分Pblock，划分位置没有明确标准
create_pblock pblock_inst_shift_low
resize_pblock [get_pblocks pblock_inst_shift_low] -add {SLICE_X2Y65:SLICE_X16Y112}
resize_pblock [get_pblocks pblock_inst_shift_low] -add {DSP48E2_X0Y26:DSP48E2_X0Y43}
resize_pblock [get_pblocks pblock_inst_shift_low] -add {RAMB18_X0Y26:RAMB18_X1Y43}
resize_pblock [get_pblocks pblock_inst_shift_low] -add {RAMB36_X0Y13:RAMB36_X1Y21}
set_property SNAPPING_MODE ON [get_pblocks pblock_inst_shift_low]
# 将inst_shift_low放到Pblock里
add_cells_to_pblock pblock_inst_shift_low [get_cells -hierarchical inst_shift_low] -clear_locs

# 划分Pblock，划分位置没有明确标准
create_pblock pblock_inst_shift_high
resize_pblock [get_pblocks pblock_inst_shift_high] -add {SLICE_X2Y124:SLICE_X13Y165}
resize_pblock [get_pblocks pblock_inst_shift_high] -add {DSP48E2_X0Y50:DSP48E2_X0Y65}
resize_pblock [get_pblocks pblock_inst_shift_high] -add {RAMB18_X0Y50:RAMB18_X1Y65}
resize_pblock [get_pblocks pblock_inst_shift_high] -add {RAMB36_X0Y25:RAMB36_X1Y32}
set_property SNAPPING_MODE ON [get_pblocks pblock_inst_shift_high]
# 将inst_shift_high放到Pblock里
add_cells_to_pblock pblock_inst_shift_high [get_cells -hierarchical inst_shift_high] -clear_locs

# 正常流程
opt_design
place_design
phys_opt_design
route_design

# route-full.dcp保存shell和初始role的布线结果
write_checkpoint /home/ict/pr_led/pr_project/led/route-full.dcp -force
# route-rp.dcp保存初始role的布线结果
write_checkpoint -cell [get_cells -hierarchical inst_shift_low] /home/ict/pr_led/pr_project/led/route-rp-inst_shift_low.dcp -force
write_checkpoint -cell [get_cells -hierarchical inst_shift_high] /home/ict/pr_led/pr_project/led/route-rp-inst_shift_high.dcp -force
# 包含shell和初始role的bitstream，-no_partial_bitfile表示不生成单独的partial bitstream
write_bitstream -no_partial_bitfile /home/ict/pr_led/hw_plat/system.bit -force

# 将布线结果中的tlpr替换为blackbox
update_design -cell [get_cells -hierarchical inst_shift_low] -black_box
update_design -cell [get_cells -hierarchical inst_shift_high] -black_box 
# 锁定布线结果
lock_design -level routing
# route-static.dcp保存shell的布线结果，供后续role布局布线使用
write_checkpoint /home/ict/pr_led/pr_project/led/route-static.dcp -force
