<script setup>
import { ref, onMounted } from 'vue'

let proto = performance.getEntries()[0].nextHopProtocol
let done = ref(false)
let count = ref(0)
let h3_count = ref(0)

onMounted(() => {
  console.log(count.value)
  console.log(`Initial request: ${proto}.`)

  setTimeout(async function () {
    while (count.value < 30 && proto !== "h3") {
      console.log("Sending request " + count.value)

      const response = await fetch("/?id=" + Math.floor(Math.random() * 1000000));

      proto = performance.getEntries()[performance.getEntries().length - 1].nextHopProtocol
      count.value++
    }

    count.value = 0

    console.log("Analyzing requests...")

    performance.getEntries().forEach(entry => {
      if (entry.nextHopProtocol !== undefined) {
        if (entry.nextHopProtocol === "h3" && entry.transferSize > 0) h3_count.value++

        if (entry.transferSize > 0) {
          count.value++
          if (proto != "h3" && entry.nextHopProtocol !== "") proto = entry.nextHopProtocol
        }

      }
    });

    console.log(count.value + " requests sent, " + h3_count.value + " used QUIC")

    // Set protocol names
    if (proto === "h3") proto = "HTTP/3"
    else if (proto === "h2") proto = "HTTP/2"
    else if (proto === "h2c") proto = "HTTP/2"
    else proto = proto.toUpperCase()

    done.value = true
  }, 1);

})

</script>

<template>
  <main>
    <img alt="Vue logo" class="logo" src="./assets/logo.svg" width="125" height="125" />

    <div v-if="done">

      <div v-if="proto === 'HTTP/3'">
        <h1>Your browser supports <span class="green bold">{{ proto }} 😉</span></h1>

        <div v-if="h3_count == count" class="bottom-text">Congratulations! Your browser sent <span
            class="green bold">every request</span> by using QUIC!</div>

        <div v-else class="bottom-text">Congratulations! Your browser upgraded the connection to QUIC after <span
            class="bold blue">{{ count }}</span> requests</div>
      </div>

      <div v-else-if="proto === 'HTTP/2'">
        <h1>Your browser used <span class="blue bold">{{ proto }}</span></h1>
        <div class="bottom-text">It appears that your network firewall is <span class="red bold">blocking QUIC</span>, or
          your browser is just not using it 😢</div>
      </div>

      <div v-else-if="proto === ''">
        <h1>Browser not supported</h1>
        <div class="bottom-text">Your browser didn't report the protocol version 😢. You can open an issue <a style="text-decoration: underline" href="https://github.com/notherealmarco/vue-quic-test/issues">on GitHub</a>.</div>
      </div>

      <div v-else>
        <h1>Your browser used <span class="red bold">{{ proto }} 😱</span></h1>
        <div class="bottom-text">This is really bad! Your browser is using a veeeery old protocol...</div>
      </div>

    </div>
    <div v-else>
      <h1>Testing your browser...</h1>
    </div>
  </main>
  <foooer class="footer">
    <a href="https://quicwg.org" target="_blank">Cool, but what the hell is QUIC?</a> | Powered by <a
      style="text-decoration: underline" href="https://github.com/notherealmarco/vue-quic-test"
      target="_blank">vue-quic-test</a>
  </foooer>
</template>

<style scoped>
main {
  line-height: 1.5;
}

.logo {
  display: block;
  margin: 0 auto 2rem;
}

.bottom-text {
  font-size: 1.05rem;
  font-weight: 400;
}

.bold {
  font-weight: 600;
}

.blue {
  color: #039be5
}

.red {
  color: #e53935
}

h1 {
  font-weight: 500;
  font-size: 1.9rem;
  top: -10px;
}

.footer {
  font-size: 0.9rem;
  text-align: center;
  margin-bottom: 1rem;
  bottom: 0;
  left: 0;
  position: absolute;
  width: 100%;
}

@media (min-width: 1024px) {
  main {
    display: flex;
    place-items: center;
  }

  .logo {
    margin: 0 2rem 0 0;
  }

  h1 {
    font-size: 2.2rem;
  }

  .bottom-text {
    font-size: 1.15rem;
  }
}
</style>
