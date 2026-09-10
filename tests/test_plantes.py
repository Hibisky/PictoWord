import json
import random
import os


PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

THEME_FILE = os.path.join(
    PROJECT_ROOT,
    "assets",
    "themes",
    "plantes.json",
)

WORDPOOL_FILE = os.path.join(
    PROJECT_ROOT,
    "assets",
    "wordpool",
    "plantes_words.json",
)


def load_json(path):
    with open(path, "r", encoding="utf-8") as file:
        return json.load(file)


def test_files_exist():
    assert os.path.exists(THEME_FILE), "Le fichier plantes.json est absent"
    assert os.path.exists(WORDPOOL_FILE), "Le fichier wordpool est absent"

    print("✅ Fichiers trouvés")


def test_questions():
    theme = load_json(THEME_FILE)
    questions = theme["questions"]

    print(f"✅ Nombre de plantes : {len(questions)}")

    answers = []

    for question in questions:
        assert "id" in question
        assert "image" in question
        assert "answer" in question

        answers.append(question["answer"])

    assert len(answers) == len(set(answers)), (
        "❌ Deux images possèdent la même réponse"
    )

    print("✅ Chaque image possède une réponse unique")


def test_wordpool():
    wordpool = load_json(WORDPOOL_FILE)
    words = wordpool["words"]

    print(f"✅ Nombre de mots disponibles : {len(words)}")

    for word in words:
        assert "word" in word
        assert "type" in word
        assert "environment" in word
        assert "difficulty" in word

    print("✅ WordPool valide")


def test_matching():
    theme = load_json(THEME_FILE)
    wordpool = load_json(WORDPOOL_FILE)

    questions = theme["questions"]
    words = wordpool["words"]

    word_names = [
        word["word"]
        for word in words
    ]

    for question in questions:
        assert question["answer"] in word_names, (
            f"❌ {question['answer']} absent du wordpool"
        )

    print("✅ Toutes les réponses existent dans WordPool")


def generate_answers(question):
    wordpool = load_json(WORDPOOL_FILE)
    words = wordpool["words"]

    correct = question["answer"]

    candidates = [
        word["word"]
        for word in words
        if word["word"] != correct
    ]

    wrong_answers = random.sample(candidates, 3)

    answers = [correct] + wrong_answers

    random.shuffle(answers)

    return answers


def play_question(question):
    answers = generate_answers(question)

    print("\n🌱 Question")
    print("----------------")
    print("Image :", question["image"])

    print("\nChoisis la bonne réponse :\n")

    for index, answer in enumerate(answers):
        print(f"{index + 1} - {answer}")

    choice = int(input("\nTa réponse : "))

    selected = answers[choice - 1]

    if selected == question["answer"]:
        print("\n✅ Bonne réponse !")
    else:
        print("\n❌ Mauvaise réponse")
        print(
            "La bonne réponse était :",
            question["answer"],
        )


if __name__ == "__main__":
    test_files_exist()
    test_questions()
    test_wordpool()
    test_matching()

    theme = load_json(THEME_FILE)

    question = random.choice(theme["questions"])

    print("\n🌱 Exemple de question")
    print("---------------------")
    print("Image :", question["image"])
    print("Réponses :")

    play_question(question)