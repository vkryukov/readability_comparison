# Readability Comparison

This project runs Elixir's [readability](https://github.com/keepcosmos/readability) library on 
the test suite for Mozilla's [readability](https://github.com/mozilla/readability) library and
compares the results.

The goal is to identify some of the cases where Elixir's algorithm is lagging behind
Mozilla's, given that Mozilla's library is more actively developed and has a test suite
of a considerable size (124 pages at the time of this writing).
