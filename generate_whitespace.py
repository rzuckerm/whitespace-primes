import sys
from pathlib import Path

from jinja2 import Environment, FileSystemLoader
from whitespace_asm import asm


def main():
    bits_per_word = 32 if len(sys.argv) < 2 else int(sys.argv[1])
    env = Environment(loader=FileSystemLoader("template"))
    template = env.get_template("primes.ws.asm.j2")
    program = template.render(W=bits_per_word) + "\n"
    dirpath = Path("whitespace")
    filepath = dirpath / f"primes-{bits_per_word}bit.ws.asm"
    dirpath.mkdir(exist_ok=True)
    filepath.write_text(program, encoding="utf-8")
    input_path = str(filepath)
    asm.main([input_path, "-o", f"{input_path.replace('.asm', '')}", "-f", "mark"])


if __name__ == "__main__":
    main()
