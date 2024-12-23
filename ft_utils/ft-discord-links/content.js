function addIntraLinks() {
    // For usernames in brackets
    document.querySelectorAll('.defaultColor_a595eb').forEach(element => {
        if (element.dataset.modified) return;
        element.dataset.modified = 'true';

        const name = element.textContent;
        const logins = name.match(/\[(.*?)\]/g);
        
        if (logins && logins.length > 0) {
            // Get the last bracketed text
            const lastLogin = logins[logins.length - 1].match(/\[(.*?)\]/)[1];
            addLink(element, lastLogin);
        }
    });

    // For guild nicknames in mutual servers
    document.querySelectorAll('.guildNick_c5a773').forEach(element => {
        if (element.dataset.modified) return;
        element.dataset.modified = 'true';

        const name = element.textContent;
        const serverName = element.closest('.listRowContent_d2d6cb')?.querySelector('.listName_d2d6cb')?.textContent;
        
        if (serverName === '1337') {
            // Get all bracketed texts and use the last one
            const logins = name.match(/\[(.*?)\]/g);
            if (logins && logins.length > 0) {
                // Extract the last login from brackets
                const lastLogin = logins[logins.length - 1].match(/\[(.*?)\]/)[1];
                addLink(element, lastLogin);
            } else {
                // If no brackets, use the nickname itself as the login
                const cleanName = name.replace(/[^\w\s-]/g, '').trim();
                addLink(element, cleanName);
            }
        }
    });
}

function addLink(element, username) {
    const link = document.createElement('a');
    link.href = `https://profile.intra.42.fr/users/${username}`;
    link.innerHTML = ' 🔗';
    link.target = '_blank';
    link.style.color = '#5865F2';
    link.style.textDecoration = 'none';
    link.onclick = e => {
        e.preventDefault();
        e.stopPropagation();
        window.open(link.href, '_blank');
    };
    element.appendChild(link);
}

new MutationObserver(() => addIntraLinks())
    .observe(document.body, {
        childList: true,
        subtree: true
    });

addIntraLinks();