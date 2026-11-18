# Pendências — Último Porto: Marés de Ferro

Este documento separa o escopo técnico já implementado e testado (baseado na Parte 1 do GDD `Último Porto Marés de Ferro.pdf`) das melhorias opcionais e dependências de design/mídia externas.

---

## 1. Concluído e Verificado (Engenharia & Lógica Core)
- [x] **Estrutura de Campanha Completa:** 25 missões em 5 capítulos, 12 diários opcionais e 3 finais condicionais.
- [x] **Sistemas Táticos de Tower Defense:** 9 defesas evoluíveis (3 níveis), sistema de materiais com atributos distintos, economia de madeira e regras de terreno/clima.
- [x] **Mecânicas Especiais:** Puzzle de prismas, rotas alternativas, tempestade, trégua narrativa e modo pós-campanha *Maré Infinita*.
- [x] **Acessibilidade e Localização:** Tradução completa PT-BR / EN, alto contraste, redução de movimento e escala de fonte.
- [x] **Motor Visual e Sonoro Procedural:** Renderização geométrica própria e síntese de áudio em runtime sem dependências externas.
- [x] **Compatibilidade Cold-Boot Headless:** Corrigida referência tipada de `MissionBoardScript` em `main.gd` para inicializar sem depender de cache `.godot/` pré-gerado pelo editor.
- [x] **CI Automático (`.github/workflows/ci.yml`):** Pipeline rodando Godot 4.7.2 headless no GitHub Actions validando `tests/campaign_test.gd` e cold-boot limpo.

---

## 2. Melhorias de Engenharia Opcionais
- [ ] **Balanceamento Quantitativo:** Simulações automatizadas de curvas de dificuldade (DP/DPS das torres versus HP das ondas em dificuldade normal/difícil sem recursos infinitos).
- [ ] **Sistema de Conquistas & Telemetria Local:** Estatísticas históricas de partidas jogadas e dano total por tipo de torre no arquivo de save.

---

## 3. Dependências Externas (Design & Assets Finais)
- [ ] **Partes 2 e 3 do GDD:** O documento atual disponível na raiz (`Último Porto Marés de Ferro.pdf`) cobre a Parte 1 de 3; expansões de lore e especificações das próximas partes dependem de documentação adicional.
- [ ] **Arte & Animações Finais (Sprites/Tilesets):** Substituição da renderização geométrica provisória por spritesheets e cenários ilustrados definitivos.
- [ ] **Trilha Sonora e Sound Design Final:** Substituição dos efeitos sintetizados proceduralmente por faixas musicais e SFX masterizados em `.ogg`/`.wav`.
- [ ] **Playtest de Usabilidade e Exportação Multiplataforma:** Geração de builds finais (`.exe`, `.apk`, WebGL) após configuração de `export_presets.cfg`.
