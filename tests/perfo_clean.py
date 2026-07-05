# Clean Test Input: PERFO — Efficient Code Snippet

Analyze the following Python code. It is intentionally efficient:

```python
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import requests

session = requests.Session()

def get_user_details_batch(user_ids):
    """Fetch full user details for a list of user IDs using batching."""
    ids_param = ",".join(map(str, user_ids))
    response = session.get(
        f"https://api.example.com/users?ids={ids_param}"
    )
    return response.json()

def find_duplicates(items):
    """Find all duplicate items in a list in O(n) time."""
    counts = Counter(items)
    return [item for item, count in counts.items() if count > 1]

def process_large_file(filename):
    """Process a large CSV file line by line with O(1) memory."""
    out_path = filename + '.processed'
    count = 0

    with open(filename, 'r') as infile, open(out_path, 'w') as outfile:
        for line in infile:
            line = line.strip()
            if not line:
                continue
            parts = line.split(',')
            new_line = ','.join([p.strip() for p in parts])
            outfile.write(new_line + '\n')
            count += 1

    return count

def fibonacci(n, memo=None):
    """Calculate Fibonacci number with memoization."""
    if memo is None:
        memo = {}
    if n in memo:
        return memo[n]
    if n <= 1:
        return n
    memo[n] = fibonacci(n - 1, memo) + fibonacci(n - 2, memo)
    return memo[n]
```

Efficiency characteristics:
- Batch API call instead of N+1 requests
- O(n) duplicate detection via Counter
- Streaming file processing (constant memory)
- Memoized Fibonacci (O(n) time instead of exponential)
