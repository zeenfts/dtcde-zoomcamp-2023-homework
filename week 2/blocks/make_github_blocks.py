from prefect.filesystems import GitHub

github_block = GitHub(
    repository="https://github.com/zeenfts/dtcde-zoomcamp-2023-homework.git"
)

github_block.get_directory("week 2/flows-prefect/.github") # specify a subfolder of repo
github__block.save("zoom-github", overwrite=True)