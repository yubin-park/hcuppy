from setuptools import setup, find_packages

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(packages=find_packages(),
    name="hcuppy",
    version="0.0.6",
    description="hcuppy is a Python implementation of HCUP Tools and Software",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Yubin Park",
    author_email="yubin.park@gmail.com",
    url="https://github.com/yubin-park/hcuppy",
    license="Apaceh 2.0", 
    install_requires = [],
    include_package_data=True,
    package_data={"": ["*.txt", "*.csv"]},
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent"
    ])


