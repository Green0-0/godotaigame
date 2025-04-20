This is a godot game-engine RPG, powered by a togetherAI llama-stack API in the background.
You should run the llama-stack API as recommended on https://llama-stack.readthedocs.io/en/latest/distributions/self_hosted_distro/together.html
```
LLAMA_STACK_PORT=8321
docker run \
  -it \
  --pull always \
  -p $LLAMA_STACK_PORT:$LLAMA_STACK_PORT \
  llamastack/distribution-together \
  --port $LLAMA_STACK_PORT \
  --env TOGETHER_API_KEY=$TOGETHER_API_KEY
```
Note that my docker port was at 32768 (not 8321, which was the port of llama stack). Depending on your configuration, the port may be different, so pay attention.

The game is a basic RPG, but with most of the core components powered by AI. An NPC agent speaks to you and can choose to give you an item. Enemies are also AI powered, and an AI determines the results of your actions, and agentically applies damage. 

![image](https://github.com/user-attachments/assets/4f106f68-ed49-46fc-b6bf-f676ddd36e33)

![image](https://github.com/user-attachments/assets/a718f49b-2f40-4a16-a242-e9fe1645c18e)

![image](https://github.com/user-attachments/assets/0e0f0618-8b68-447c-bf51-2ea84852cf72)

![image](https://github.com/user-attachments/assets/7c07e4da-fb63-4032-a467-1ea2c5417d25)

![image](https://github.com/user-attachments/assets/17465ba8-55b0-4e0a-90e9-64f7d0fe8da5)




Credits to M-Art for music, pixabay for sound effects, and itch.io for the artwork used.
