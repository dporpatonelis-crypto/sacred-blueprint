#!/usr/bin/env python3
"""Shared schema contract for protected History Explorer 3D scenarios."""

import json
from copy import deepcopy
from pathlib import Path


REQUIRED_KEYS = {"characters", "dialogs", "facts", "screens", "props"}
OPTIONAL_KEYS = {"interactive", "character_interactives", "completion", "quiz"}
CONTENT_KEYS = {"dialogs", "facts", "screens"} | OPTIONAL_KEYS
MEDIA_KEYS = {"video_url", "target_screen", "label"}
QUIZ_KEYS = {
    "id",
    "host_prop_id",
    "host_name",
    "host_title",
    "intro",
    "pass_score",
    "reward_text",
    "reward_audio_url",
    "reward_interactive",
    "questions",
}
QUESTION_KEYS = {
    "id",
    "prompt",
    "options",
    "correct_index",
    "explanation",
    "audio_url",
}


def fail(message: str):
    raise ValueError(f"History3D contract error: {message}")


def load_json(path):
    path = Path(path)
    with path.open(encoding="utf-8") as source:
        return json.load(source)


def write_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as destination:
        json.dump(value, destination, ensure_ascii=False, indent=2)
        destination.write("\n")


def nonempty_string(value):
    return isinstance(value, str) and bool(value.strip())


def valid_media_url(value):
    return nonempty_string(value) and value.strip().startswith(
        ("http://", "https://", "/")
    )


def validate_interactive(media, path):
    if not isinstance(media, dict):
        fail(f"{path} must be an object")
    unexpected = set(media) - MEDIA_KEYS
    if unexpected:
        fail(f"{path} contains unsupported fields: {', '.join(sorted(unexpected))}")
    if not valid_media_url(media.get("video_url")):
        fail(f"{path}.video_url must start with http://, https:// or /")
    if "target_screen" in media and media["target_screen"] not in {"left", "right"}:
        fail(f"{path}.target_screen must be left or right")
    if "label" in media and not isinstance(media["label"], str):
        fail(f"{path}.label must be a string")


def validate_screens(screens):
    expected = {
        "left_image_url",
        "right_image_url",
        "left_label",
        "right_label",
    }
    if not isinstance(screens, dict) or set(screens) != expected:
        fail("screens must contain exactly the two media URLs and labels")
    for key in ("left_image_url", "right_image_url"):
        value = screens[key]
        if not isinstance(value, str):
            fail(f"screens.{key} must be a string")
        if value.strip() and not valid_media_url(value):
            fail(f"screens.{key} must start with http://, https:// or /")
    for key in ("left_label", "right_label"):
        if not isinstance(screens[key], str):
            fail(f"screens.{key} must be a string")


def validate_full_scenario(candidate, template):
    if not isinstance(candidate, dict) or not isinstance(template, dict):
        fail("scenario and template must be objects")

    actual_keys = set(candidate)
    missing = REQUIRED_KEYS - actual_keys
    unexpected = actual_keys - REQUIRED_KEYS - OPTIONAL_KEYS
    if missing:
        fail(f"missing top-level keys: {', '.join(sorted(missing))}")
    if unexpected:
        fail(f"unexpected top-level keys: {', '.join(sorted(unexpected))}")

    if candidate.get("characters") != template.get("characters"):
        fail("protected characters/models differ from templates/history3d/default.json")
    if candidate.get("props") != template.get("props"):
        fail("protected props differ from templates/history3d/default.json")

    allowed_ids = {
        character.get("id")
        for character in template.get("characters", [])
        if isinstance(character, dict)
    }
    allowed_prop_ids = {
        prop.get("id")
        for prop in template.get("props", [])
        if isinstance(prop, dict)
    }

    dialogs = candidate.get("dialogs")
    facts = candidate.get("facts")
    if not isinstance(dialogs, list) or not isinstance(facts, list):
        fail("dialogs and facts must be arrays")

    for index, dialog in enumerate(dialogs):
        if (
            not isinstance(dialog, dict)
            or set(dialog) != {"character_id", "question", "answer"}
            or dialog.get("character_id") not in allowed_ids
            or not nonempty_string(dialog.get("question"))
            or not nonempty_string(dialog.get("answer"))
        ):
            fail(f"invalid dialogs[{index}]")

    for index, fact in enumerate(facts):
        if (
            not isinstance(fact, dict)
            or set(fact) != {"character_id", "fact"}
            or fact.get("character_id") not in allowed_ids
            or not nonempty_string(fact.get("fact"))
        ):
            fail(f"invalid facts[{index}]")

    validate_screens(candidate.get("screens"))

    if "interactive" in candidate:
        validate_interactive(candidate["interactive"], "interactive")

    if "character_interactives" in candidate:
        interactives = candidate["character_interactives"]
        if not isinstance(interactives, dict):
            fail("character_interactives must be an object")
        for character_id, media in interactives.items():
            if character_id not in allowed_ids:
                fail(f"unknown character_interactives id: {character_id}")
            validate_interactive(media, f"character_interactives[{character_id!r}]")

    if "completion" in candidate:
        completion = candidate["completion"]
        if not isinstance(completion, dict):
            fail("completion must be an object")
        unexpected = set(completion) - {
            "required_character_ids",
            "reward_interactive",
        }
        if unexpected:
            fail(
                "completion contains unsupported fields: "
                + ", ".join(sorted(unexpected))
            )
        required_ids = completion.get("required_character_ids")
        if (
            not isinstance(required_ids, list)
            or not required_ids
            or any(character_id not in allowed_ids for character_id in required_ids)
        ):
            fail("completion.required_character_ids contains invalid ids")
        if "reward_interactive" in completion:
            validate_interactive(
                completion["reward_interactive"],
                "completion.reward_interactive",
            )

    if "quiz" in candidate:
        quiz = candidate["quiz"]
        if not isinstance(quiz, dict):
            fail("quiz must be an object")
        unexpected = set(quiz) - QUIZ_KEYS
        if unexpected:
            fail(f"quiz contains unsupported fields: {', '.join(sorted(unexpected))}")

        questions = quiz.get("questions")
        if (
            not nonempty_string(quiz.get("id"))
            or not nonempty_string(quiz.get("host_prop_id"))
            or quiz.get("host_prop_id") not in allowed_prop_ids
            or not nonempty_string(quiz.get("reward_text"))
            or not isinstance(questions, list)
            or not questions
        ):
            fail("quiz is missing a valid id, host prop, reward or questions")

        pass_score = quiz.get("pass_score")
        if (
            isinstance(pass_score, bool)
            or not isinstance(pass_score, int)
            or not 1 <= pass_score <= len(questions)
        ):
            fail("quiz.pass_score must be between 1 and the question count")

        for key in ("host_name", "host_title", "intro"):
            if key in quiz and not isinstance(quiz[key], str):
                fail(f"quiz.{key} must be a string")
        if "reward_audio_url" in quiz and not valid_media_url(
            quiz["reward_audio_url"]
        ):
            fail("quiz.reward_audio_url is invalid")
        if "reward_interactive" in quiz:
            validate_interactive(
                quiz["reward_interactive"],
                "quiz.reward_interactive",
            )

        for index, question in enumerate(questions):
            if not isinstance(question, dict):
                fail(f"quiz.questions[{index}] must be an object")
            unexpected = set(question) - QUESTION_KEYS
            if unexpected:
                fail(
                    f"quiz.questions[{index}] contains unsupported fields: "
                    + ", ".join(sorted(unexpected))
                )
            options = question.get("options")
            correct_index = question.get("correct_index")
            if (
                not nonempty_string(question.get("id"))
                or not nonempty_string(question.get("prompt"))
                or not isinstance(options, list)
                or len(options) < 2
                or any(not nonempty_string(option) for option in options)
                or isinstance(correct_index, bool)
                or not isinstance(correct_index, int)
                or not 0 <= correct_index < len(options)
            ):
                fail(f"invalid quiz.questions[{index}]")
            if "explanation" in question and not isinstance(
                question["explanation"], str
            ):
                fail(f"quiz.questions[{index}].explanation must be a string")
            if "audio_url" in question and not valid_media_url(
                question["audio_url"]
            ):
                fail(f"quiz.questions[{index}].audio_url is invalid")

    return candidate


def build_scenario(template, content):
    if not isinstance(content, dict):
        fail("content overlay must be an object")

    missing = {"dialogs", "facts", "screens"} - set(content)
    unexpected = set(content) - CONTENT_KEYS
    if missing:
        fail(f"content overlay is missing: {', '.join(sorted(missing))}")
    if unexpected:
        fail(
            "content overlay contains protected or unsupported fields: "
            + ", ".join(sorted(unexpected))
        )

    result = deepcopy(template)
    for key in ("dialogs", "facts", "screens"):
        result[key] = deepcopy(content[key])
    for key in ("interactive", "character_interactives", "completion", "quiz"):
        if key in content:
            result[key] = deepcopy(content[key])

    validate_full_scenario(result, template)
    return result
