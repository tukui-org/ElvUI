# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "discord.py",
#     "Unidecode",
# ]
# ///

import os
import re
import discord
from unidecode import unidecode

API_TOKEN = os.environ['DISCORD_TOKEN'] 
PATREON_ROLE = 211510894679556097

class TukuiCommunityBot(discord.Client):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.patrons = []
        self.patrons_lua = 'local DONATORS = {'

    def clean_patrons(self):
        self.patrons = [unidecode(patron) for patron in self.patrons]
        self.patrons = sorted(self.patrons, key=str.lower)

    def wrap_patrons(self):
        for patron in self.patrons:
            self.patrons_lua += f"\n\t'{patron}',"
        self.patrons_lua += '\n}'

    def write_patrons(self):
        with open('ElvUI_Options/Game/Shared/Core.lua', 'r', encoding='utf-8') as f:
            payload = f.read()
        result = re.sub(
            r'(-- Automated by Discord Bot)(.*?)(-- End of automation)',
            rf'\1\n{self.patrons_lua}\n\3',
            payload,
            flags=re.DOTALL
        )
        with open('ElvUI_Options/Game/Shared/Core.lua', 'w', encoding='utf-8') as f:
            f.write(result)

    async def on_ready(self):
        for guild in client.guilds:
            for role in guild.roles:
                if role.id == PATREON_ROLE:
                    for member in role.members:
                        self.patrons.append(member.display_name)
        self.clean_patrons()
        self.wrap_patrons()
        self.write_patrons()
        await client.close()

intents = discord.Intents.default()
intents.members = True

client = TukuiCommunityBot(intents=intents)

if __name__ == '__main__':
  client.run(API_TOKEN)