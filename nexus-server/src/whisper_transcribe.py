import sys
import whisper

def format_timestamp(seconds: float) -> str:
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    seconds = int(seconds % 60)
    milliseconds = int((seconds - int(seconds)) * 1000)
    return f"{hours:02}:{minutes:02}:{seconds:02},{milliseconds:03}"

def transcribe_audio() -> dict:
    model = whisper.load_model("medium")
    return model.transcribe(sys.argv[1])

def format_transcript(transcript: dict):
    segments = transcript["segments"]
    formatted_transcript = ""

    for i, segment in enumerate(segments):
        start_time = format_timestamp(segment["start"])
        end_time = format_timestamp(segment["end"])
        text = segment["text"].strip()
        formatted_transcript += f"{i + 1}\n"
        formatted_transcript += f"{start_time} --> {end_time}\n"
        formatted_transcript += f"{text}\n\n"

    return formatted_transcript

def main():
    transcript = transcribe_audio()
    formatted = format_transcript(transcript)
    print(formatted)

if __name__ == "__main__":
    main()
