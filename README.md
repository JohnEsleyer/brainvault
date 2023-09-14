<div align="center">
  <img src="https://github.com/JohnEsleyer/BrainVault/assets/66754038/46ce5349-ba5c-4617-91c7-1671c0b67aff" alt="Image" width="140"/>
</div>

<p align="center">
<h1 align="center">BrainVault</h1>
</p>

#  Introduction
BrainVault is an advance markdown-based note-taking application that serves as your dedicated personal knowledge repository. With a focus on retention, this app sets itself apart by being more opinionated in its approach. BrainVault reimagines the concept of notes, treating them as flashcards rather than mere documents. Designed to store concise information snippets in a more simpler a way.

### Screenshots

![Screenshot from 2023-08-26 17-59-56](https://github.com/JohnEsleyer/BrainVault/assets/66754038/9343fb62-1b0a-4460-bb66-82b50b01f3c3)
![Screenshot from 2023-08-26 17-33-23](https://github.com/JohnEsleyer/BrainVault/assets/66754038/a3d184f7-be47-428c-b343-619722cfe346)![Screenshot from 2023-08-26 17-33-29](https://github.com/JohnEsleyer/BrainVault/assets/66754038/64d8a4ec-eba8-432f-8f40-1e51c641ca8e)
![Screenshot from 2023-08-26 18-24-15](https://github.com/JohnEsleyer/BrainVault/assets/66754038/ffba4154-247b-48b7-9c83-9484b1d7be8e)


**Personal Note**: This application was primarily intended to function as my personal note-taking app. It drew inspiration from two well-known applications: Obsidian Notes and Anki. I created this app because I wanted to blend the markdown writing style from Obsidian with the process of crafting flashcards. Currently, I use this app along with the aforementioned note taking apps (Obsidian and Anki). I use BrainVault to save quick bits of information like code examples, word meanings, and brief facts. On the other hand, when I want to keep things that are all linked together, I opt for Obsidian.

---
### How does the BrainVault organize notes?
The app employs a streamlined organizational structure characterized by two fundamental tiers: subjects and topics, each housing a distinct level of content granularity. With subjects serving as overarching categories and topics providing subcategories within subjects, the hierarchy allows for a concise and manageable system. 

The conscious decision to limit the hierarchy to three levels aims to uphold efficiency and optimize the learning process by preventing the proliferation of intricate structures that could overshadow the core goal of assimilating information. This approach acknowledges the potential drawbacks of complex hierarchies, which can divert attention from studying and pose challenges in navigation as the structure expands. Consequently, the system underscores a judicious balance between organization and the primary objective of effective knowledge retention and acquisition.

**Hierarchy**
- Subjects
  - Topics
    - Notes

At the top level, subjects are created to encapsulate broader areas of knowledge or study. These might include subjects such as Programming, Science , History, and more. Each subject can holda  collection of related topics.
Topics, nested within the subjects, offer a means to further categorize information within a specific subject area. For instance, under the Programming subject, topics could include Variables, Loops, Functions, and the like.
The ultimate building blocks, notes, resides within individual topics. These notes contain the actual pieces of information you want to remember or refer back to. They could be detailed explanations, definitions, formulas, or any other relevant content.

**Why only 3 levels?**

The decision to limit the hierarchy is motivated by the aim to prevent users from creating convoluted systems that might eventually detract from the learning experience. As the structure becomes more intricate, traversing through the tree of information can become cumbersome and counterproductive.

---
# Features
- Study mode: Turn a subject or topic section into a deck of flashcards.
- Markdown editor
- Auto-save

 ### Supported Markdown Features
- Three types of headers denoted by the '#' symbol (e.g. #, ##, ###)
- Bold text (\*\**Bold Text***)
- Italic text (\_Italic text_)
- Embedded Images
- Bullet using the '-' symbol
- Code blocks (Supports 100+ Programming Languages):

![image](https://github.com/JohnEsleyer/BrainVault/assets/66754038/f85e6dae-5a22-402d-93a7-0758514f04f5)
![image](https://github.com/JohnEsleyer/BrainVault/assets/66754038/cf273f76-8697-464f-8be5-d1d8e309753f)

### Two-sided section
You can add a two-sided section in your notes:
![image](https://github.com/JohnEsleyer/BrainVault/assets/66754038/c7113ec1-949f-41e3-b230-38d8225d5e78)

![twosided](https://github.com/JohnEsleyer/BrainVault/assets/66754038/2510b10b-d3c1-4055-9b1b-2e89ec6f9e8e)

### Supported Platforms
- Android
- Linux
- Windows (Not Tested)
- Web (In development)

---
# Installation
### Android
Open the terminal and type the following
```
flutter build apk --release
```
### Linux
```
flutter build linux --release
```
### Windows (Not tested)
I haven't tested the application in windows yet because all my computers are running in Linux.
```
flutter build windows --release
```

# Limitations
- The application is still very slow.
- Doesn't support Latex 

# Contributing
I welcome any contributions from the open-source community to make this project better. However, I must emphasize that a positive and respectful environment is paramount.  My lines of code aren't flawless, they reflect a work in progress. Many of them may not be fully optimized and lack a refined structure. Your collaboration and constructive input are valued as we collectively work towards improvement.

### Making Contributions
1. Fork the repository and create a new branch for your contribution.
2. Write meaningful commit messages.
3. Submit a pull request to the main branch of this repository.
