import subprocess
import sys
import tempfile
import time


def main():
    bits_per_word = int(sys.argv[1])
    sieve_size = int(sys.argv[2])
    program = f"whitespace/primes-{bits_per_word}bit.ws"
    with tempfile.NamedTemporaryFile("wt") as f:
        f.write(str(sieve_size))
        f.flush()
        f.seek(0)
        start = time.time()
        result = subprocess.run(
            ["whitespace", program], stdout=subprocess.PIPE, stdin=f, encoding="utf-8"
        )
        elapsed = time.time() - start
        if result.returncode == 0:
            decode_output(result.stdout, bits_per_word, sieve_size)

        print(f"Elapsed time: {elapsed:.3f}s")
        exit(result.returncode)


def decode_output(output, bits_per_word, sieve_size):
    values = [int(word) for word in output.split()]
    prime_count = 0
    if sieve_size >= 2:
        print("2", end="")
        prime_count += 1
        for n in range(3, sieve_size + 1, 2):
            b = (n - 3) // 2
            index = b // bits_per_word
            mask = 1 << (b % bits_per_word)
            if (values[index] & mask) == 0:
                print(f", {n}", end="")
                prime_count += 1

        print()

    print(f"#primes={prime_count}")


if __name__ == "__main__":
    main()
