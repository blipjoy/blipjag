use std::env;
use thiserror::Error;

#[derive(Debug, Error)]
enum Error {
    #[error("Missing cli argument: Path")]
    MissingArg,

    #[error("I/O Error: {0}")]
    Io(#[from] std::io::Error),
}

fn main() -> Result<(), Error> {
    let mut args = env::args_os().skip(1);

    match args.next() {
        None => return Err(Error::MissingArg),
        Some(path) => {
            let source = std::fs::read_to_string(path)?;
            let (bin, _) = customasm::assemble_str_to_binary(&source);

            std::fs::write("output.bin", bin.unwrap())?;
        }
    }

    Ok(())
}
