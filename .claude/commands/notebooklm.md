# NotebookLM Skill

Use this skill to interact with Google NotebookLM programmatically via the `notebooklm-py` library (https://github.com/teng-lin/notebooklm-py).

## Setup

Install the library:
```bash
pip install notebooklm-py
# For browser-based login:
pip install "notebooklm-py[browser]"
```

Authenticate:
```bash
notebooklm login
```

## How to Help the User

When the user invokes `/notebooklm`, understand their intent from the arguments and assist with one or more of the following workflows:

---

### 1. Notebook Management

**List notebooks:**
```python
import asyncio
from notebooklm import NotebookLMClient

async def main():
    async with await NotebookLMClient.from_storage() as client:
        notebooks = await client.notebooks.list()
        for nb in notebooks:
            print(nb.id, nb.title)

asyncio.run(main())
```

**Create a notebook:**
```python
nb = await client.notebooks.create("My Research")
```

**Delete / rename:**
```python
await client.notebooks.delete(notebook_id)
await client.notebooks.rename(notebook_id, "New Title")
```

---

### 2. Adding Sources

```python
# Add a URL
await client.sources.add_url(nb.id, "https://example.com", wait=True)

# Add a local file (PDF, audio, video, image, etc.)
await client.sources.add_file(nb.id, "./paper.pdf", wait=True)

# Add plain text
await client.sources.add_text(nb.id, "My Notes", "Content here...")

# Add a Google Drive file
await client.sources.add_drive(nb.id, drive_file_id)
```

---

### 3. Chat / Q&A

```python
result = await client.chat.ask(nb.id, "Summarize the key findings")
print(result.answer)

# Follow-up in same conversation
result2 = await client.chat.ask(
    nb.id,
    "What are the limitations?",
    conversation_id=result.conversation_id
)
```

---

### 4. Generate Artifacts

```python
# Audio overview (podcast)
status = await client.artifacts.generate_audio(
    nb.id,
    instructions="make it engaging",
    audio_format="deep_dive",   # or "overview"
    audio_length="medium"       # "short", "medium", "long"
)
await client.artifacts.wait_for_completion(nb.id, status.task_id)
await client.artifacts.download_audio(nb.id, "podcast.mp3")

# Video overview
status = await client.artifacts.generate_video(
    nb.id,
    video_format="explainer",   # "explainer", "tutorial", etc.
    visual_style="vibrant"      # "vibrant", "whiteboard", etc.
)

# Quiz
status = await client.artifacts.generate_quiz(
    nb.id,
    quantity="medium",    # "few", "medium", "more"
    difficulty="medium"   # "easy", "medium", "hard"
)
await client.artifacts.wait_for_completion(nb.id, status.task_id)
await client.artifacts.download_quiz(nb.id, "quiz.json", output_format="json")  # or "markdown", "html"

# Flashcards
status = await client.artifacts.generate_flashcards(nb.id)
await client.artifacts.download_flashcards(nb.id, "cards.json")

# Report / Briefing doc
status = await client.artifacts.generate_report(
    nb.id,
    report_format="briefing_doc"  # or "faq", "timeline", etc.
)
await client.artifacts.download_report(nb.id, "report.md")

# Study guide
await client.artifacts.generate_study_guide(nb.id)

# Mind map
await client.artifacts.generate_mind_map(nb.id)
await client.artifacts.download_mind_map(nb.id, "mindmap.json")

# Infographic
await client.artifacts.generate_infographic(
    nb.id,
    orientation="landscape",  # or "portrait"
    detail_level="medium"
)
await client.artifacts.download_infographic(nb.id, "infographic.png")

# Slide deck
await client.artifacts.generate_slide_deck(nb.id)
await client.artifacts.download_slide_deck(nb.id, "slides.pdf", output_format="pdf")  # or "pptx"

# Data table
await client.artifacts.generate_data_table(nb.id, instructions="compare key concepts")
await client.artifacts.download_data_table(nb.id, "data.csv")
```

---

### 5. Research (Auto-import from web or Drive)

```python
# Start web research
task = await client.research.start(nb.id, "artificial intelligence trends", research_type=1)

# Poll for results
results = await client.research.poll(nb.id)

# Import discovered sources
await client.research.import_sources(nb.id, task["task_id"], results["sources"], wait=True)
```

---

### 6. Sharing

```python
# Get sharing status
status = await client.sharing.get_status(nb.id)

# Make public / private
await client.sharing.set_public(nb.id, True)

# Add collaborator
await client.sharing.add_user(
    nb.id,
    "colleague@example.com",
    permission="editor",  # "viewer" or "editor"
    notify=True
)
```

---

### 7. CLI Reference

```bash
notebooklm login                          # Authenticate
notebooklm create "Research Project"     # Create notebook
notebooklm use <notebook_id>             # Set active notebook
notebooklm source add <url_or_path>      # Add source
notebooklm ask "What are the key themes?" # Chat
notebooklm generate audio "engaging summary" --wait
notebooklm generate video --style whiteboard --wait
notebooklm generate quiz --difficulty hard
notebooklm generate flashcards
notebooklm generate slide-deck
notebooklm generate infographic
notebooklm generate mind-map
notebooklm generate data-table "compare concepts"
notebooklm download audio ./podcast.mp3
notebooklm download quiz --format markdown ./quiz.md
notebooklm download slide-deck ./slides.pptx --format pptx
notebooklm metadata --json
notebooklm share status
notebooklm skill install                 # Install Claude Code skill integration
```

---

## Instructions for Claude

1. **Read the user's `$ARGUMENTS`** to determine what they want to do with NotebookLM.
2. **Check if `notebooklm-py` is installed**: run `pip show notebooklm-py` and install if missing.
3. **Write Python code** using the async `NotebookLMClient` API patterns shown above, or use CLI commands for simpler tasks.
4. **Execute** the code via Bash and show results.
5. If the user hasn't authenticated, guide them to run `notebooklm login` first.
6. For long-running generation tasks, always call `wait_for_completion` before downloading.
