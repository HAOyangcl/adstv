import os

# ========= 配置项 =========
# 你的项目 lib 目录路径（请改成你本地的实际路径）
LIB_DIR = "./lib"
# 输出的 Markdown 文件路径
OUTPUT_MD = "flutter_project_code_export.md"
# 需要导出的文件后缀及对应 Markdown 语言标识
SUPPORT_EXT = {
    ".dart": "dart",
    ".md": "markdown",
    ".txt": "text"
}
# 忽略的目录/文件（按需添加）
IGNORE_PATTERNS = [
    ".git",
    ".idea",
    "build",
    ".vscode"
]
# ==========================


def should_ignore(path: str) -> bool:
    """判断文件/目录是否需要忽略"""
    for pattern in IGNORE_PATTERNS:
        if pattern in path:
            return True
    return False


def export_flutter_lib_to_md():
    with open(OUTPUT_MD, "w", encoding="utf-8") as md_file:
        # 写入文档标题
        md_file.write("# Flutter 项目 lib 目录代码导出\n\n")
        md_file.write("> 自动生成的项目代码文档，按目录结构整理\n\n")

        # 遍历 lib 目录
        for root, dirs, files in os.walk(LIB_DIR):
            # 过滤忽略的目录
            if should_ignore(root):
                continue

            # 计算当前目录的相对路径（用于标题层级）
            rel_root = os.path.relpath(root, LIB_DIR)
            if rel_root == ".":
                current_dir = "lib/"
            else:
                current_dir = f"lib/{rel_root}"

            # 写入目录标题（根据层级设置 # 数量）
            depth = len(rel_root.split(os.sep)) if rel_root != "." else 0
            md_file.write(f"{'#' * (depth + 2)} 📂 {current_dir}\n\n")

            # 遍历当前目录下的文件
            for file in files:
                # 过滤忽略的文件
                if should_ignore(file):
                    continue

                # 获取文件后缀
                file_ext = os.path.splitext(file)[1]
                if file_ext not in SUPPORT_EXT:
                    continue

                # 拼接文件路径
                file_path = os.path.join(root, file)
                rel_file_path = os.path.relpath(file_path, LIB_DIR)
                full_file_path = f"lib/{rel_file_path}"

                # 写入文件标题
                md_file.write(f"#### 📄 `{full_file_path}`\n\n")

                # 读取文件内容
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read()
                except UnicodeDecodeError:
                    md_file.write("> ❌ 无法读取文件（编码错误）\n\n")
                    continue

                # 写入 Markdown 代码块
                lang = SUPPORT_EXT[file_ext]
                md_file.write(f"```{lang}\n{content}\n```\n\n")

        print(f"✅ 导出完成！文件已保存到：{os.path.abspath(OUTPUT_MD)}")


if __name__ == "__main__":
    export_flutter_lib_to_md()