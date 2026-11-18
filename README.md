# Último Porto: Marés de Ferro (`Jogo-TowerDefense-UltimoPorto`)

Jogo tático de **Tower Defense** com campanha narrativa em **Godot Engine 4.7** (GDScript 2.0), estruturado em 25 missões e 5 capítulos, economia de materiais, puzzle de prismas, múltiplos finais condicionais, acessibilidade integrada e suíte de testes headless automatizada.

---

## 1. Arquitetura e Sistemas Implementados (`game/scripts/`)

- **Campanha e Narrativa (`campaign_data.gd`, `campaign_story.gd`, `mission_board.gd`):**
  - 25 missões com 5 ondas de inimigos por mapa, encontros autorais e chefes de capítulo.
  - 12 diários opcionais desbloqueados por maestria (conclusão sem dano ao cais).
  - Escolhas narrativas com impacto real, puzzle de prismas (`prism_puzzle.gd`) e 3 finais distintos (*Maré Calma*, *Maré Domada* e *Porto Aberto*).
  - Modo pós-campanha *Maré Infinita*.
- **Combate, Defesas e Materiais (`combat_rules.gd`, `tower_picker.gd`):**
  - 9 tipos de defesas com evolução em 3 níveis (Balista, Canhão, Farol Antiaéreo, etc.).
  - Sistema modular de materiais (Madeira, Pedra, Ferro, Aço, Cristal-Maré) que altera alcance, cadência, perfuração de armadura e custo.
- **Inimigos e Modificadores de Terreno (`mission_routes.gd`, `board_painter.gd`):**
  - Inimigos terrestres, aéreos, blindados, sapadores e chefes.
  - Eventos ambientais dinâmicos (rotas alternativas na missão 8, tempestade na missão 17 e trégua na missão 19).
- **Áudio & Efeitos Visuais Procedurais (`combat_effects.gd`):**
  - Arte geométrica desenhada via código (zero assets externos obrigatórios) e efeitos sonoros sintetizados em tempo de execução via `AudioStreamWAV`.
- **Localização e Acessibilidade (`localization.gd`, `ui_accessibility.gd`, `settings_panel.gd`):**
  - Suporte completo a Português (PT-BR) e Inglês (EN).
  - Modo de alto contraste, redução de movimento (câmera/partículas) e ajuste dinâmico de tamanho de texto.
- **Persistência (`campaign_save.gd`):**
  - Salvamento automático em `user://campaign_save.json`.

---

## 2. Como Executar e Testar

### Requisitos
- **Godot Engine 4.7.2+** (Standard / GL Compatibility).

### Abrir no Editor ou Jogar
1. Importe `game/project.godot` na Godot Engine.
2. Execute a cena principal (`res://scenes/main.tscn`) com **F5**.

### Testes Automatizados (Headless)
Execute a suíte de validação técnica diretamente via linha de comando (inclusive em ambientes sem interface gráfica / CI):

```bash
# Validação completa de campanha, ondas, localização, save e acessibilidade
godot --headless --path game --script res://tests/campaign_test.gd

# Teste de inicialização limpa (cold-boot) sem cache do editor
godot --headless --path game --quit-after 10
```

Para acompanhar o roadmap e pendências de arte/design, consulte [PENDENCIAS.md](PENDENCIAS.md).
