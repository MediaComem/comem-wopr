<script>
  import { currentGame } from './stores';
  import { delay, uuidv4 } from './utils';

  let playing = false;
  let thinking = false;

  $: rows = Array(3).fill().map((_, i) => $currentGame.board.slice(i * 3, i * 3 + 3));

  const play = cell => async () => {
    if (playing || thinking) {
      return;
    }

    playing = true;
    try {
      const res = await fetch('/api/actions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          cell,
          ai: $currentGame.ai,
          game: $currentGame.id,
          number: $currentGame.board.reduce((memo, cell) => memo + (cell ? 1 : 0), 1)
        })
      });

      if (res.status !== 201) {
        playing = false;
        return;
      }

      const body = await res.json();
      currentGame.play(cell, 'X', body.state !== 'playing' ? body.state : undefined);

      playing = false;
      if (body.enemyCell !== undefined) {
        thinking = true;
        await delay(Math.random() * 1000);
        currentGame.play(body.enemyCell, 'O', body.state);
        thinking = false;
      }
    } catch (err) {
      playing = false;
      thinking = false;
      console.warn(err);
    }
  }
</script>

<style>
  table {
    border-collapse: collapse;
    cursor: pointer;
  }
  table td {
    border: 1px solid black;
    width: 1em;
    height: 1em;
    text-align: center;
    vertical-align: middle;
  }
  table td:hover {
    background-color: #eeeeee;
  }
  table tr:first-child td {
    border-top: 0;
  }
  table tr:last-child td {
    border-bottom: 0;
  }
  table tr td:first-child {
    border-left: 0;
  }
  table tr td:last-child {
    border-right: 0;
  }
</style>

<table>
  {#each rows as row, rowIndex}
    <tr>
      {#each row as cell, columnIndex}
        <td on:click={play(rowIndex * 3 + columnIndex)}>{cell || '•'}</td>
      {/each}
    </tr>
  {/each}
</table>

{#if thinking}
  <p>Thinking...</p>
{:else if playing}
  <p>Submitting your move...</p>
{:else if $currentGame.state === 'playing'}
  <p>Your turn.</p>
{:else if $currentGame.state === 'win'}
  <p><strong>You win!.</strong></p>
{:else if $currentGame.state === 'lose'}
  <p><strong>You lose.</strong></p>
{:else if $currentGame.state === 'draw'}
  <p><strong>How about a nice game of chess?</strong></p>
{/if}