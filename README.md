<!--                                                                                  -->
<!--  The following parts of c-tree-carver contain new code released under the        -->
<!--  BSD 2-Clause License:                                                           -->
<!--  * `bin`                                                                         -->
<!--  * `cpp/src/debug.hpp`                                                           -->
<!--  * `cpp/src/debug_printers.cpp`                                                  -->
<!--  * `cpp/src/debug_printers.hpp`                                                  -->
<!--  * `cpp/src/source_range_hash.hpp`                                               -->
<!--  * `lib`                                                                         -->
<!--  * `test`                                                                        -->
<!--                                                                                  -->
<!--  Copyright (c) 2022 Dhruv Makwana                                                -->
<!--  All rights reserved.                                                            -->
<!--                                                                                  -->
<!--  This software was developed by the University of Cambridge Computer             -->
<!--  Laboratory as part of the Rigorous Engineering of Mainstream Systems            -->
<!--  (REMS) project. This project has been partly funded by an EPSRC                 -->
<!--  Doctoral Training studentship. This project has been partly funded by           -->
<!--  Google. This project has received funding from the European Research            -->
<!--  Council (ERC) under the European Union's Horizon 2020 research and              -->
<!--  innovation programme (grant agreement No 789108, Advanced Grant                 -->
<!--  ELVER).                                                                         -->
<!--                                                                                  -->
<!--  BSD 2-Clause License                                                            -->
<!--                                                                                  -->
<!--  Redistribution and use in source and binary forms, with or without              -->
<!--  modification, are permitted provided that the following conditions              -->
<!--  are met:                                                                        -->
<!--  1. Redistributions of source code must retain the above copyright               -->
<!--     notice, this list of conditions and the following disclaimer.                -->
<!--  2. Redistributions in binary form must reproduce the above copyright            -->
<!--     notice, this list of conditions and the following disclaimer in              -->
<!--     the documentation and/or other materials provided with the                   -->
<!--     distribution.                                                                -->
<!--                                                                                  -->
<!--  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''              -->
<!--  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED               -->
<!--  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A                 -->
<!--  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR             -->
<!--  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,                    -->
<!--  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT                -->
<!--  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF                -->
<!--  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND             -->
<!--  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,              -->
<!--  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT              -->
<!--  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF              -->
<!--  SUCH DAMAGE.                                                                    -->
<!--                                                                                  -->
<!--  All other parts involve adapted code, with the new code subject to the          -->
<!--  above BSD 2-Clause licence and the original code subject to its MIT             -->
<!--  licence.                                                                        -->
<!--                                                                                  -->
<!--  The MIT License (MIT)                                                           -->
<!--                                                                                  -->
<!--  Copyright (c) 2016 Takaaki Hiragushi                                            -->
<!--                                                                                  -->
<!--  Permission is hereby granted, free of charge, to any person obtaining a copy    -->
<!--  of this software and associated documentation files (the "Software"), to deal   -->
<!--  in the Software without restriction, including without limitation the rights    -->
<!--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell       -->
<!--  copies of the Software, and to permit persons to whom the Software is           -->
<!--  furnished to do so, subject to the following conditions:                        -->
<!--                                                                                  -->
<!--  The above copyright notice and this permission notice shall be included in all  -->
<!--  copies or substantial portions of the Software.                                 -->
<!--                                                                                  -->
<!--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR      -->
<!--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        -->
<!--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     -->
<!--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          -->
<!--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   -->
<!--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   -->
<!--  SOFTWARE.                                                                       -->
<!--                                                                                  -->

c-tree-carver
====

Carves C source trees into files suitable for verification tools.

This tool performs tree-carving on a C source-tree given some root functions,
by retaining only the used declarations.

It is developed to extract and verify progressively larger parts of
pKVM, without having to support irrelevant C constructs.

## Installation

### Prerequisites

- C++ 17 compiler
- LLVM/Clang 15.0.7 (see CI workflow)
- CMake >= 3.16.3
- OCaml & Libraries (see opam file)

### Build


```
opam install .
```


## Usage

```
c-tree-carve --help
```

*YOU MUST HAVE A `compile_commands.json` FILE IN YOUR SOURCE DIRECTORY.*
Futhermore, it must use *relative* paths.

```
cd cpp
./test/run_test.py make # make compile_commands.json file
c-tree-carve test/array/array_initialiser.in.c
```

| Option              | Meaning |
|---------------------|---------|
| `-d`                | Output program debug info to stderr. |
| `-n num`            | Choose a command (`compile_commands.json` can have more than one command per file) |
| `-r func1,..,funcn` | Choose traversal root functions from file (defaults to all) |

The remaining options are from [Clang's
CommonOptionParser](https://clang.llvm.org/doxygen/classclang_1_1tooling_1_1CommonOptionsParser.html#details).

## Running Tests

```
dune runtest && cd cpp && ./test/run_test.py make && ./test/run_test.py for
```

This makes a `compile_commands.json` file for all the test inputs and then runs
all the tests. Additional options in `./test/run_test.py -h`.

## To Do

- [x] C constructs required for `kvm_pgtable_walk` in `pgtable.c`
- [x] Command line interface and support for `compile_commands.json`
- [x] Support for reproducing directory structure
- [x] Fix up tests
- [x] Support macro dependencies
- [x] Comment out instead of ommitting irrelevant lines
- [x] Support retaining relevant includes
- [x] Make build system straightforward
- [x] Input validation for top-level decls
- [x] Source locations for comment-simplifier
- [x] Update CI
- [ ] Input validation for struct/union fields
- [ ] End-to-end tests
- [ ] Add licenses/headache for tests?
- [ ] Use `ASTContext::getTypeInfo` to fill in missing struct fields
- [ ] Add new tests for new functionality (`test/to-add`, input validation, buddy allocator)
- [ ] Example for README.md

## Funding

This software was developed by the University of Cambridge Computer
Laboratory as part of the Rigorous Engineering of Mainstream Systems
(REMS) project. This project has been partly funded by an EPSRC
Doctoral Training studentship. This project has been partly funded by
Google. This project has received funding from the European Research
Council (ERC) under the European Union's Horizon 2020 research and
innovation programme (grant agreement No 789108, Advanced Grant
ELVER).

## History

The initial implementation and tests
were taken from [cpp-simplifier](https://github.com/logicmachine/cpp-simplifier/).
