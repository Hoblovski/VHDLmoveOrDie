project文件组织
    build/
        quartus的文件们
    doc/
        写的文档之类的
    png2mif/
        TODO
    res/
        .mif文件之类的 资源文件
    src/
        源代码文件
        keydecoder/
            将键盘输入转换成wasd信号 (wasddecoder.vhd)
        top/
            顶层entity, 看项目的话从它开始看
        utils/
            一些通用的工具 (分时, 计数器, 输出数字管编码)
        vga/
            现在只有moveController.vhd和vga640480.vhd是有意义的
            moveController.vhd是一个 最简单的移动控制 (wasd -> x, y)

如果你要加东西
    1. cd src
    2. mkdir MODULE_NAME (比如clientlogic之类的)
    3. 在src/MODULE_NAME里面写代码
    4. cd src/top
    5. 修改top.vhd, 运行检查你的代码
