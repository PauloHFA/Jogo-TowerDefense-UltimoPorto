# Último Porto: Marés de Ferro

Protótipo de campanha em Godot 4.7, implementado com base na Parte 1 do documento de game design disponível na raiz do projeto.

## Executar

1. Instale o Godot 4.7 ou mais recente.
2. Importe `game/project.godot` no Godot.
3. Execute com **F6/F5** ou o botão Play.

## Jogar

- Na campanha, selecione qualquer missão já desbloqueada e escolha **Preparar missão**.
- Selecione uma defesa no menu, escolha **Construir** e clique em um terreno livre. Não é possível bloquear a rota dos Cascos.
- Selecione uma construção no mapa para melhorá-la; clique com o botão direito para vendê-la pela metade do custo.
- **Material** alterna entre os materiais liberados no capítulo. Eles afetam custo, poder, alcance, durabilidade, perfuração de armadura e cadência de tiro.
- Inicie cinco ondas com o botão ou com **Espaço**. As defesas atacam automaticamente; inimigos derrotados rendem madeira.
- Durante o combate, use **Pausar**, **P** ou **Esc** para pausar/retomar; em construção, **Esc** cancela a seleção.
- Um diário opcional é encontrado ao concluir sua missão sem perder vida do cais.
- O botão **Campanha** retorna ao mapa fora do combate.
- O progresso, materiais disponíveis, diários e escolha final são salvos em `user://campaign_save.json`.
- **Configurações** permite alternar português/inglês, reduzir movimento, ativar alto contraste, ampliar textos e ajustar os efeitos sonoros.

## Conteúdo implementado

- 25 missões em cinco capítulos, com os cenários, novidades e batidas de história descritos no GDD.
- Seleção de missão e desbloqueios por progressão.
- Oito defesas com três níveis, incluindo defesa antiaérea, materiais com atributos diferentes e economia de madeira.
- Inimigos aéreos, blindados, sapadores e chefes; rotas alternativas na missão 8, tempestade na missão 17 e trégua durante a missão 19.
- Encontros e rotas próprios por missão, resistências/fraquezas de inimigos e sinergias entre defesas.
- Puzzle de prismas, 12 diários opcionais, escolhas narrativas com consequências, três finais condicionais e modo pós-campanha Maré Infinita.
- Interface e narrativa localizadas em português e inglês, com tutorial inicial e opções de acessibilidade.
- Animações exageradas de movimento/reação, projéteis, partículas, tremor de câmera e efeitos sonoros sintetizados em tempo de execução.
- Arte provisória desenhada no próprio jogo, sem dependências de assets externos.

## Testes

```powershell
godot --headless --path game --script res://tests/campaign_test.gd
godot --headless --path game --quit-after 5
```

O teste automatizado cobre dados, rotas, localização, acessibilidade, pausa, salvamento e uma simulação das cinco ondas de cada missão com recursos abundantes. Essa simulação verifica a conclusão técnica dos encontros, mas não representa o balanceamento de uma partida normal.

## Escopo desta versão

O arquivo de design disponível se identifica como Parte 1 de 3. As Partes 2 e 3 ainda não foram fornecidas. O balanceamento e os encontros precisam de playtests e ajustes; os mapas têm rotas próprias, mas ainda usam arte geométrica provisória. Também faltam as Partes 2 e 3 do GDD, sprites/arte e animações finais, áudio e música finais, trailer, testes de partidas completas e validação ampla de acessibilidade. Esses materiais e a conferência de requisitos ausentes dependem de arquivos e decisões do projeto; não podem ser substituídos por código sem inventar conteúdo.
