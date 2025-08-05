# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Apache Spark

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Architecture, Optimization, and Best Practices Day 1 Lecture

| Concept                | Notes            |
|---------------------|------------------|
| **Apache Spark**  | - Spark is a distributed compute framework that allows you to process very large amounts of data efficiently <br> &emsp;• The successor of Hadoop/ Java MapReduce<br><br>- **Benefits to Spark** <br> &emsp;• Spark leverages RAM much more effectively than previous iterations of distributed compute<br> &emsp;&emsp;• It's *way* faster than Hive/Java MR/etc<br> &emsp;• Spark is storage agnostic, allowing a decoupling of storage and compute<br> &emsp;&emsp;• Spark makes it easier to avoid vendor lock-in<br> &emsp;• Spark has a huge community of developers so StackOverflow/Chat GPT will help you troubleshoot <br><br>- **When Spark Isn't So Good**<br> &emsp;• Nobody else in the company knows Spark<br> &emsp;&emsp;• Spark is not immune to the bus factor<br> &emsp;• Your company already uses something else a lot<br> &emsp;&emsp;• Inertia is often times not worth it to overcome <br> &emsp;• Homogeneity of pipelines matters!|
| **How Spark Works**  | - The plan<br>- The driver<br>- The executors <br>- Using basketball as an analogy, the **plan** is the basketball play, the **driver** is the coach, and the **executors** are the basketball players |
| **The Plan**  | - The driver *tells the executor what to do* via the plan <br> &emsp;• This is the transformation you describe in Python, Scala, or SQL <br>- The plan is evaluated lazily <br> &emsp;• ***Lazy evaluation: Execution only happens when it needs to***<br>- When does execution "need to" happen? <br> &emsp;• Writing output <br> &emsp;• When part of the plan depends on the data itself <br> &emsp;&emsp;• (e.g. calling `dataframe.collect()` to ) |
| **The Driver**  | - The driver *reads the plan* <br>- Important Spark driver settings<br> &emsp;• `spark.driver.memory`<br> &emsp;&emsp;• The amount of memory the driver has to process the job <br> &emsp;&emsp;&emsp;• 2-16 GB range <br> &emsp;&emsp;• For complex jobs or jobs that use `dataframe.collect()`, you may need to bump this higher, or else *you'll experience out of memory*<br> &emsp;• `spark.driver.memoryOverheadFactor`<br> &emsp;&emsp;• What fraction the driver needs for non-heap related memory, usually 10%, might need to be higher for complex jobs |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx
