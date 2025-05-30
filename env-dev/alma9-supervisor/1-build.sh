#!/bin/bash
set -e

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR" # 确保在脚本目录执行

# 镜像和服务信息 (与 docker-compose.yaml 保持一致)
IMAGE_NAME="shuai/alma-dev"
IMAGE_TAG="1.0"
IMAGE_FULL="${IMAGE_NAME}:${IMAGE_TAG}"
CONTAINER_NAME="shuai-alma-dev"

# 统一输出标题
echo "========== Building AlmaLinux 9 (Supervisord) Development Environment =========="
echo "Image: ${IMAGE_FULL}"

# 设置环境变量优化构建 (保留)
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export PYTHONUNBUFFERED=1
export CONDA_DISABLE_PROGRESS_BARS=1

# 停止并删除旧容器（使用 docker-compose down）
# 检查容器是否存在比检查 compose 项目状态更可靠
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container defined in docker-compose.yaml..."
    # 使用 docker-compose down 清理相关资源
    docker-compose down --remove-orphans || echo "'docker-compose down' failed, continuing build..."
fi

# 开始构建容器 (使用 docker-compose build)
echo "Starting build process using docker-compose..."
echo "Note: This may take a while, please be patient..."

if docker-compose build; then
    echo "========== Build Complete =========="
    echo "Image ${IMAGE_FULL} built successfully."
    echo "To start the container, run: ./2-dev-cli.sh start"
else
    echo "Build failed using docker-compose."
    exit 1
fi 