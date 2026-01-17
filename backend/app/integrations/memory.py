class ShortTermMemory:
    def __init__(self, max_turns=6):
        self.history = []
        self.max_turns = max_turns

    def add(self, role, message):
        self.history.append(f"{role.upper()}: {message}")
        if len(self.history) > self.max_turns:
            self.history = self.history[-self.max_turns:]

    def get_context(self):
        if not self.history:
            return "No previous conversation."
        return "\n".join(self.history)

    def clear(self):
        self.history = []
