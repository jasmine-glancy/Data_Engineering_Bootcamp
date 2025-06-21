
# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> KPI and Experimentation

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> KPIs and Experimentation: Setting up and Analysing Experiments Day 1 Lab

### Set up the lab code

1. Pull from main
2. set STATvariable ENV
3. `python src/server.py`

### Using Flask and Python to Connect With Statsig

```python
@app.route('/tasks', methods=['GET'])
def get_tasks():
    random_num = request.args.get('random')
    
    # The user's hashed IP address
    hash_string = request.remote_addr

    if random_num:
        # Changes the userID to a random number to allow them to be distributed randomly into different experimental groups for unbiased results
        hash_string = str(random.randint(0, 10000000))

    user_id = str(hash(hash_string))
```

### Statsig Experiments

- Once you start an experiment, you can not change the groups or parameters!
- If you pick stable ID for a local environment, you will only have one group

### Logging with Statsig

`statsig.log_event('visited_signup')`

Server-side logging is preferred as a starting point in setting up experiments because it is easier to set up.

### Finding logged events

Experiments -> choose the experiment -> diagnostics

- Feature gates
  - You don't get groups, only a "yes" or a "no"
  - Good for two outcomes
  - Can sometimes be simpler to work with than experiments
    - You can edit things whenever you want with feature gates

### Monitoring Metrics

- If any of the bars overlap with 0, it means the effect can be positive or negative (it doesn't matter much)
- The Alpha value (i.e. `α = 0.1`) is the probability you are saying its not a coincidence when it is a coincidence

### Metrics Cataloging

#### Tags

- You can add tags such as ***gaurdrail metrics***
  - Guardrail metrics are metrics that are so important to the business, if an experiment causes these numbers to go down, *the experiment is blocked from deploying*
  - Prevents data scientists and data engineers from "going wild"
  - Must be ***fresh and high quality*** when you create them because they *stop experiments*. Must be trusted!

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What do Guardrail metrics do?
- What platform is being used in the lab to set up the experiment for button color variation?
- What is the purpose of setting a random user ID in the experiment?
- What is a feature gate primarily used for?
- Why is server-side logging preferred as a starting point in setting up experiments?
- What does a gaurdrail metric ensure in an experiment?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

Experiments are one of the most important ways to have impact as a data engineer! Experiments can be launched with Statsig. It's important to create guardrail metrics with fresh and high-quality metrics to ensure your experiments are not  inappropriately stopped. Feature gates can be used as an easy alternative to experiments if only a binary answer is required.
