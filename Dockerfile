# -----------------------------------------------------------------------------
# (1) NVIDIA CUDA 런타임 이미지를 베이스로 사용 (버전은 원하는 대로 교체 가능)
# -----------------------------------------------------------------------------
    FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

    # -----------------------------------------------------------------------------
    # (2) 필수 패키지 설치 & COLMAP PPA를 통한 COLMAP 설치
    # -----------------------------------------------------------------------------
    ENV DEBIAN_FRONTEND=noninteractive
    RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common \
        wget \
        && rm -rf /var/lib/apt/lists/*
    
    RUN add-apt-repository ppa:colmap/colmap -y
    RUN apt-get update && apt-get install -y --no-install-recommends colmap \
        && rm -rf /var/lib/apt/lists/*
    
    # -----------------------------------------------------------------------------
    # (3) Miniconda 설치
    # -----------------------------------------------------------------------------
    WORKDIR /tmp
    RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
        && rm Miniconda3-latest-Linux-x86_64.sh
    ENV PATH="/opt/conda/bin:${PATH}"
    
    # -----------------------------------------------------------------------------
    # (4) conda 환경 생성
    #     아래 단계에서 environment.yml을 복사하고, conda env를 만든다
    # -----------------------------------------------------------------------------
    COPY environment.yml /tmp/environment.yml
    
    # conda 업데이트 후 환경 생성
    RUN conda update -n base -c defaults conda -y && \
        conda env create -f /tmp/environment.yml && \
        conda clean --all -f -y
    
    # (conda activate gh-3dgs)를 기본으로 쓰고 싶다면, bash 접속시 자동 활성화 설정
    RUN echo "conda activate gh-3dgs" >> /root/.bashrc
    
    # 이후 모든 작업 디렉토리
    WORKDIR /workspace
    
    # -----------------------------------------------------------------------------
    # (5) 컨테이너 실행 시 기본 쉘
    # -----------------------------------------------------------------------------
    CMD ["/bin/bash"]
    